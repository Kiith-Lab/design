import 'package:design/dashboards.dart';
import 'package:design/project.dart';
import 'package:design/view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
    return ShadApp.cupertino(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Container(
                margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/phinmaed.png',
                          fit: BoxFit.contain,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedIndex == 0
                            ? 'Phinma Education'
                            : _selectedIndex == 1
                                ? 'View User'
                                : 'Project',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          showShadDialog(
                            context: context,
                            builder: (BuildContext dialogContext) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ShadDialog(
                                title: const Text('Settings'),
                                child: Container(
                                  width: 100,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 400,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              ShadCard(
                                                width: double.infinity,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      ShadAvatar(
                                                        'https://avatars.githubusercontent.com/u/124599?v=4',
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Username",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            Text(
                                                              "gmail",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ShadCard(
                                                width: double.infinity,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Text("Forgot Password?")
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ShadButton.destructive(
                                    child: const Text('Logout'),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://avatars.githubusercontent.com/u/124599?v=4',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Stack(
              children: [
                _selectedWidget,
              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green, Colors.white],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BottomNavigationBar(
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Icon(
                            Icons.home_rounded,
                            key: ValueKey<int>(_selectedIndex == 0 ? 1 : 0),
                            color:
                                _selectedIndex == 0 ? Colors.teal : Colors.grey,
                          ),
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Icon(
                            Icons.person_outline,
                            key: ValueKey<int>(_selectedIndex == 1 ? 1 : 0),
                            color:
                                _selectedIndex == 1 ? Colors.teal : Colors.grey,
                          ),
                        ),
                        label: 'View User',
                      ),
                      BottomNavigationBarItem(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Icon(
                            FontAwesomeIcons.folder,
                            key: ValueKey<int>(_selectedIndex == 2 ? 1 : 0),
                            color:
                                _selectedIndex == 2 ? Colors.teal : Colors.grey,
                          ),
                        ),
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
            ),
          );
        },
      ),
    );
  }
}
