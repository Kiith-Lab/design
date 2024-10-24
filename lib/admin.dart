import 'package:design/dashboards.dart';
import 'package:design/login.dart';
import 'package:design/main.dart';
import 'package:design/project.dart';
import 'package:design/user_verification.dart';
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

class _AdminState extends State<Administrator>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    // Update length to 4
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 50 && _isAppBarVisible) {
      setState(() {
        _isAppBarVisible = false;
      });
    } else if (_scrollController.offset <= 50 && !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = true;
      });
    }
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                      _tabController.index >= 0
                          ? (_tabController.index == 0
                              ? 'Phinma Education'
                              : _tabController.index == 1
                                  ? 'Archive User'
                                  : _tabController.index == 2
                                      ? 'User Verification'
                                      : 'Project')
                          : 'Default Title',
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
                        _showSettingsDialog(context);
                      },
                      child: const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://avatars.githubusercontent.com/u/124599?v=4',
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50.0),
                  child: Container(
                    color: Colors.green,
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.green.shade300,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey.shade400,
                      tabs: const <Tab>[
                        Tab(icon: FaIcon(FontAwesomeIcons.house)),
                        Tab(
                            icon: Icon(
                          Icons.manage_accounts,
                          size: 32,
                        )),
                        Tab(
                            icon: Icon(
                          Icons.verified_user,
                          size: 32,
                        )),
                        Tab(icon: FaIcon(FontAwesomeIcons.folder)),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const <Widget>[
              Dashboards(),
              ViewUserPage(),
              UserVerification(),
              ProjectPage(),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/124599?v=4',
                    ),
                  ),
                  title: Text("Username"),
                  subtitle: Text("gmail"),
                ),
                const Divider(),
                TextButton(
                  onPressed: () {
                    // Add forgot password functionality if needed
                  },
                  child: const Text("Forgot Password?"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginAppes(),
                  ),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
