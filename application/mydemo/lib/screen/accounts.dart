import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';


enum SensorType { temperature, humidity, pressure }

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.title});
  final String title;

  @override
  State<AccountPage> createState() => _AccountList();
}

class _AccountList extends State<AccountPage> {
  final List<Map<String, dynamic>> items = [
    {
      'user_id': 'U01',
      'role': 'Quản lý',
      'created_at': '2023-10-10 10:10:10'
    },
    {
      'user_id': 'U02',
      'role': 'Nhân viên',
      'created_at': "2023-10-08 09:10:10"
    },
    {
      'user_id': 'U03',
      'role': 'Nhân viên',
      'created_at': "2023-10-08 08:10:10"
    },
    {
      'user_id': 'U04',
      'role': 'Nhân viên',
      'created_at': "2023-10-08 07:10:10"
    },
    {
      'user_id': 'U05',
      'role': 'Nhân viên',
      'created_at': "2023-10-08 07:10:10"
    }
    
  ];

  DateFormat formatter = DateFormat('yyyy/MM/dd');
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  List<SensorType> selectedSensorTypes = [];
  String userID = '';
  String pwd = '';
  List<String> options = ['Quản lý', 'Nhân viên'];
  String _role = 'Nhân viên';

   


  void showSearchPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Tạo tài khoản', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          userID = value;
                        });
                      },
                      decoration: InputDecoration(hintText: 'Nhập mã nhân viên'),
                    ),
                    SizedBox(height: 10, width: 10),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          pwd = value;
                        });
                      },
                      decoration: InputDecoration(hintText: 'Nhập mật khẩu'),
                    ),
                    SizedBox(height: 10, width: 10),
                    Row(
                        children: [
                          Text('Vai trò:', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10, width: 10),
                          DropdownButton(
                            value: _role,
                            items: options.map((String option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                print(newValue);
                                _role = newValue!;
                                print('Role $_role');
                              });
                            },
                          ),
                      ]
                    ),
                ],
              ), 
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Thực hiện hành động tìm kiếm ở đây
                    // Ví dụ: gọi một API để tìm kiếm theo từ khóa
                    print('Mã nhân viên: $userID');
                    Navigator.of(context).pop();
                  },
                  child: Text('Thêm'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Đóng popup khi nhấn nút Hủy
                    Navigator.of(context).pop();
                  },
                  child: Text('Hủy'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Users';
    List<String> options = ['Nhiệt độ', 'Độ ẩm'];
    String selectedOption = options[0];

    // Dialog errorDialog = 
// showDialog(context: context, builder: (BuildContext context) => errorDialog);}

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(title),
          actions: [
            IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showSearchPopup(context);
            },
          ),
          ],
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.centerLeft,
                    child: Text("Mã nhân viên: " + items[index]['user_id']),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Vai trò: " + items[index]['role']),
                    alignment: Alignment.centerLeft,
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Thời gian tạo: " + items[index]['created_at']),
                    alignment: Alignment.centerLeft,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


class PlaceholderDialog extends StatelessWidget {
  const PlaceholderDialog({
    this.icon,
    this.title,
    this.message,
    this.actions = const [],
    Key? key,
  }) : super(key: key);

  final Widget? icon;
  final String? title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      icon: icon,
      title: title == null
          ? null
          : Text(
              title!,
              textAlign: TextAlign.center,
            ),
      // titleTextStyle: AppStyle.bodyBlack,
      content: message == null
          ? null
          : Text(
              message!,
              textAlign: TextAlign.center,
            ),
      // contentTextStyle: AppStyle.textBlack,
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowButtonSpacing: 8.0,
      actions: actions,
    );
  }
}