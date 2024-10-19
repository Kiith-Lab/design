import 'package:design/define.dart';
import 'package:design/devpage.dart';
import 'package:design/emphathize.dart';
import 'package:design/facilitatorModule.dart';
import 'package:design/ideate.dart';
import 'package:design/listpage.dart';
import 'package:design/main.dart';
import 'package:design/myproject.dart';
import 'package:design/prototype.dart';
import 'package:design/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Secondpage extends StatelessWidget {
  const Secondpage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme:
            const IconThemeData(size: 22.0, color: Colors.white70),
        backgroundColor: Colors.green.shade700,
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.logout, color: Colors.white),
            backgroundColor: Colors.green.shade700,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginAppes()),
                          );
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
            label: 'LOGOUT',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.white,
          ),
          SpeedDialChild(
            child: const Icon(Icons.people, color: Colors.white),
            backgroundColor: Colors.green.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FacilitatorModule()),
              );
            },
            label: 'FACILITATORS MODULE',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.white,
          ),
          SpeedDialChild(
            child: const Icon(Icons.list, color: Colors.white),
            backgroundColor: Colors.green.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListPage()),
              );
            },
            label: 'MY DESIGN THINKING LIST',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.white,
          ),
          SpeedDialChild(
            child: const Icon(Icons.info, color: Colors.white),
            backgroundColor: Colors.green.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DevPage()),
              );
            },
            label: 'DEVELOPER INFO',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.white,
          ),
          SpeedDialChild(
            child: const Icon(Icons.folder, color: Colors.white),
            backgroundColor: Colors.green.shade700,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyProjectPage()),
              );
            },
            label: 'CREATE PROJECT',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            labelBackgroundColor: Colors.white,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/Design_Thinking_Five_Modes_Page.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0)
                      .copyWith(top: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MODES',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: const Color.fromARGB(255, 240, 240, 240),
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return _buildCard(
                              gradientColors: [Colors.blue, Colors.blueAccent],
                              text: 'EMPATHIZE',
                              imageAsset: 'assets/images/bg.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Empathize()),
                                );
                              },
                            );
                          case 1:
                            return _buildCard(
                              gradientColors: [
                                Colors.green,
                                Colors.greenAccent
                              ],
                              text: 'DEFINE',
                              imageAsset: 'assets/images/def.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Define()),
                                );
                              },
                            );
                          case 2:
                            return _buildCard(
                              gradientColors: [
                                Colors.orange,
                                Colors.deepOrangeAccent
                              ],
                              text: 'IDEATE',
                              imageAsset: 'assets/images/idea.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Ideate()),
                                );
                              },
                            );
                          case 3:
                            return _buildCard(
                              gradientColors: [Colors.red, Colors.redAccent],
                              text: 'PROTOTYPE',
                              imageAsset: 'assets/images/pr.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Prototype()),
                                );
                              },
                            );
                          case 4:
                            return _buildCard(
                              gradientColors: [
                                Colors.purple,
                                Colors.purpleAccent
                              ],
                              text: 'TEST',
                              imageAsset: 'assets/images/test.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Test()),
                                );
                              },
                            );
                          default:
                            return Container();
                        }
                      },
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Powered by PHINMA COC CITE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required List<Color> gradientColors,
    required String text,
    required String imageAsset,
    void Function()? onTap,
    double cardHeight = 90.0,
    double borderRadius = 12.0,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  }) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: cardHeight,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Image.asset(
                  imageAsset,
                  width: 40.0,
                  height: 40.0,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
