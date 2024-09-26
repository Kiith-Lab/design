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
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;
  bool _isBottomNavBarVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 50 && _isAppBarVisible) {
      setState(() {
        _isAppBarVisible = false;
        _isBottomNavBarVisible = false;
      });
    } else if (_scrollController.offset <= 50 && !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = true;
        _isBottomNavBarVisible = true;
      });
    }
  }

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
            body: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    snap: true,
                    backgroundColor: Colors.green,
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
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                                  actions: [
                                    ShadButton.destructive(
                                      child: const Text('Logout'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                  ],
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        ShadAvatar(
                                                          'https://avatars.githubusercontent.com/u/124599?v=4',
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
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
                                                        const EdgeInsets.all(
                                                            8.0),
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
                                ),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://avatars.githubusercontent.com/u/124599?v=4',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ];
              },
              body: _selectedWidget,
            ),
            bottomNavigationBar: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _isBottomNavBarVisible ? kBottomNavigationBarHeight : 0,
              child: Wrap(
                children: [
                  BottomNavigationBar(
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
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                      switch (index) {
                        case 0:
                          setState(() {
                            _selectedWidget = const Dashboards();
                          });
                          break;
                        case 1:
                          setState(() {
                            _selectedWidget = const ViewUserPage();
                          });
                          break;
                        case 2:
                          setState(() {
                            _selectedWidget = const ProjectPage();
                          });
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
