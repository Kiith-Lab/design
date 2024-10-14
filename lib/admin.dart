import 'package:design/dashboards.dart';
import 'package:design/login.dart';
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

class _AdminState extends State<Administrator>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                          _tabController.index == 0
                              ? 'Phinma Education'
                              : _tabController.index == 1
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
                              builder: (BuildContext context) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ShadDialog(
                                  title: const Text('Settings'),
                                  actions: [
                                    ShadButton.destructive(
                                      child: const Text('Logout'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginAppes(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: const Column(
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
                                                        EdgeInsets.all(8.0),
                                                    child: Row(
                                                      children: [
                                                        ShadAvatar(
                                                          'https://avatars.githubusercontent.com/u/124599?v=4',
                                                        ),
                                                        SizedBox(width: 5),
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
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                ShadCard(
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
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
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(50.0),
                      child: Container(
                        color: Colors.green,
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.green.shade300,
                            // Changed from circular to rectangular
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey.shade400,
                          tabs: const <Tab>[
                            Tab(icon: FaIcon(FontAwesomeIcons.house)),
                            Tab(icon: FaIcon(FontAwesomeIcons.user)),
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
                  ProjectPage(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
