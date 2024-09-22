import 'package:design/dashboard.dart';
import 'package:design/project.dart';
import 'package:design/view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const Administrator());
}

class Administrator extends StatefulWidget {
  const Administrator({super.key});

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Administrator> {
  int _selectedIndex = 0;
  Widget _selectedWidget = const Dashboards();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Image.asset(
                    'assets/images/phinmaed.png',
                    fit: BoxFit.contain,
                    height: 50,
                  ),
                  const SizedBox(width: 5),
                  Text(_selectedIndex == 0
                      ? 'Phinma Education'
                      : _selectedIndex == 1
                          ? 'View User'
                          : 'Project'),
                ],
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: const Text('Settings'),
                        content: Container(
                          width: 300,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://avatars.githubusercontent.com/u/124599?v=4'),
                                ),
                                title: Text("Username"),
                                subtitle: Text("gmail"),
                              ),
                              Divider(),
                              ListTile(
                                title: Text("Forgot Password?"),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Logout'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://avatars.githubusercontent.com/u/124599?v=4'),
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                _selectedWidget,
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: BottomNavigationBar(
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      label: 'View User',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(FontAwesomeIcons.folder),
                      label: 'Project',
                    ),
                  ],
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.teal,
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    switch (index) {
                      case 0:
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedWidget = const Dashboards();
                          });
                        });
                        break;
                      case 1:
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedWidget = const ViewUserPage();
                          });
                        });
                        break;
                      case 2:
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        Future.delayed(const Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedWidget = const ProjectPage();
                          });
                        });
                        break;
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}