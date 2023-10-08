import 'package:flutter/material.dart';
import 'package:mydemo/screen/monitor.dart';
import 'package:mydemo/screen/accounts.dart';
import 'package:mydemo/screen/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<HomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    MonitorPage(title: "Monitor"),
    AccountPage(title: "Accounts"),
    ProfilePage(title: "Profile"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // switch(index){
      //   case 0:
      //     Navigator.pushNamed(context, '/monitor');
      //     break;
      //   case 1:
      //     Navigator.pushNamed(context, '/users');
      //     break;
      //   case 2:
      //     Navigator.pushNamed(context, '/profile');
      //     break;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('BottomNavigationBar Sample'),
      // ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}