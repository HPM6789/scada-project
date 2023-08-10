package config

import (
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path"
	"sync"
	"time"

	"github.com/joho/godotenv"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"

	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
)

type OrgSetup struct {
	PORT         string
	OrgName      string
	CryptoPath   string
	CertPath     string
	KeyPath      string
	TLSCertPath  string
	PeerEndpoint string
	GatewayPeer  string
	Gateway      client.Gateway
}

var (
	instance *AppConfig = nil
	once     sync.Once
)

func getEnv(key string, fallback interface{}) interface{} {
	var rValue interface{}
	value, exists := os.LookupEnv(key)
	if !exists {
		rValue = fallback
	} else {
		rValue = value
	}
	return rValue
}

func InitConfig() *AppConfig {
	log.Printf("Initializing connection for %s...\n", setup.OrgName)
	once.Do(
		func() {
			if err := godotenv.Load(); err != nil {
				log.Fatal("Error loading .env file")
			}

			instance = &AppConfig{
				PORT:         getEnv("PORT", "").(string),
				OrgName:      getEnv("ORG_NAME", "").(string),
				CryptoPath:   getEnv("CRYPTO_PATH", "").(string),
				CertPath:     getEnv("CERT_PATH", "").(string),
				KeyPath:      getEnv("KEY_PATH", "").(string),
				TLSCertPath:  getEnv("TLS_CERT_PATH", "").(string),
				PeerEndpoint: getEnv("PEER_ENDPOINT", "").(string),
				GatewayPeer:  getEnv("GATEWAY_PEER", "").(string),
			}
		},
	)

	clientConnection := instance.newGrpcConnection()
	id := instance.newIdentity()
	sign := instance.newSign()

	gateway, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(clientConnection),
		client.WithEvaluateTimeout(5*time.Second),
		client.WithEndorseTimeout(15*time.Second),
		client.WithSubmitTimeout(5*time.Second),
		client.WithCommitStatusTimeout(1*time.Minute),
	)
	if err != nil {
		panic(err)
	}
	instance.Gateway = *gateway
	log.Println("Initialization complete")

	return instance
}

func loadCertificate(filename string) (*x509.Certificate, error) {
	certificatePEM, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read certificate file: %w", err)
	}
	return identity.CertificateFromPEM(certificatePEM)
}

// newSign creates a function that generates a digital signature from a message digest using a private key.
func (setup *OrgSetup) newSign() identity.Sign {
	files, err := ioutil.ReadDir(setup.KeyPath)
	if err != nil {
		panic(fmt.Errorf("failed to read private key directory: %w", err))
	}
	privateKeyPEM, err := ioutil.ReadFile(path.Join(setup.KeyPath, files[0].Name()))

	if err != nil {
		panic(fmt.Errorf("failed to read private key file: %w", err))
	}

	privateKey, err := identity.PrivateKeyFromPEM(privateKeyPEM)
	if err != nil {
		panic(err)
	}

	sign, err := identity.NewPrivateKeySign(privateKey)
	if err != nil {
		panic(err)
	}

	return sign
}

// newIdentity creates a client identity for this Gateway connection using an X.509 certificate.
func (setup *OrgSetup) newIdentity() *identity.X509Identity {
	certificate, err := loadCertificate(setup.CertPath)
	if err != nil {
		panic(err)
	}

	id, err := identity.NewX509Identity(setup.MSPID, certificate)
	if err != nil {
		panic(err)
	}

	return id
}

// newGrpcConnection creates a gRPC connection to the Gateway server.
func (setup *OrgSetup) newGrpcConnection() *grpc.ClientConn {
	certificate, err := loadCertificate(setup.TLSCertPath)
	if err != nil {
		panic(err)
	}

	certPool := x509.NewCertPool()
	certPool.AddCert(certificate)
	transportCredentials := credentials.NewClientTLSFromCert(certPool, setup.GatewayPeer)

	connection, err := grpc.Dial(setup.PeerEndpoint, grpc.WithTransportCredentials(transportCredentials))
	if err != nil {
		panic(fmt.Errorf("failed to create gRPC connection: %w", err))
	}

	return connection
}
