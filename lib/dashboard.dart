import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MaterialApp(home: Dashboard()));
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Dashboards(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Dashboards extends StatefulWidget {
  const Dashboards({super.key});

  @override
  _DashboardsState createState() => _DashboardsState();
}

class _DashboardsState extends State<Dashboards> {
  int projectCount = 0;
  List<dynamic> projects = [];
  int userCount = 0;
  List<dynamic> users = [];
  int schoolCount = 0;
  List<dynamic> schools = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProjects();
    fetchUsers();
    fetchSchools();
  }

  Future<void> fetchProjects() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/view.php'),
        body: {'operation': 'getProjects'},
      );

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        final List<dynamic> fetchedProjects;

        if (decodedResponse is Map) {
          if (decodedResponse.containsKey('error')) {
            print('Error from server: ${decodedResponse['error']}');
            return;
          }
          fetchedProjects = [decodedResponse];
        } else if (decodedResponse is List) {
          fetchedProjects = decodedResponse;
        } else {
          print('Unexpected response format');
          return;
        }

        setState(() {
          projects = fetchedProjects;
          projectCount = projects.length;
        });

        print('Fetched ${projects.length} projects');
      } else {
        print('Failed to fetch projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/view.php'),
        body: {'operation': 'getUser'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedUsers = json.decode(response.body);
        setState(() {
          users = fetchedUsers;
          userCount = users.length;
        });
        print('Fetched ${users.length} users');
      } else {
        print('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> fetchSchools() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/view.php'),
        body: {'operation': 'getSchool'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedSchools = json.decode(response.body);
        setState(() {
          schools = fetchedSchools;
          schoolCount = schools.length;
        });
        print('Fetched ${schools.length} schools');
      } else {
        print('Failed to fetch schools: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schools: $e');
    }
  }

  void _showList(BuildContext context, String title, List<dynamic> items,
      String nameKey, String descriptionKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<dynamic> filteredItems = items.where((item) {
              final name = item[nameKey]?.toString().toLowerCase() ?? '';
              final description =
                  item[descriptionKey]?.toString().toLowerCase() ?? '';
              return name.contains(_searchQuery.toLowerCase()) ||
                  description.contains(_searchQuery.toLowerCase());
            }).toList();

            return Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search $title...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search, color: Colors.teal),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        style: const TextStyle(color: Colors.teal),
                        cursorColor: Colors.teal,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final name = item[nameKey]?.toString() ?? 'No Name';
                          final description =
                              item[descriptionKey]?.toString() ??
                                  item['school_country']?.toString() ??
                                  'No Description';
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Text(
                                  name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () {
                                // Handle tap event
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/Design_Thinking_Admin.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                        'User Accounts',
                        userCount.toString(),
                        Icons.person,
                        Colors.blue,
                        () => _showList(context, 'User Accounts', users,
                            'users_firstname', 'role_name'),
                      ),
                      _buildInfoCard(
                        'Projects',
                        projectCount.toString(),
                        Icons.folder,
                        Colors.orange,
                        () => _showList(context, 'Projects', projects,
                            'project_title', 'users_firstname'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                        'Instructors',
                        '89',
                        FontAwesomeIcons.userPlus,
                        Colors.purple,
                        () {},
                      ),
                      _buildInfoCard(
                        'School',
                        schoolCount.toString(),
                        FontAwesomeIcons.school,
                        Colors.green,
                        () => _showList(context, 'Schools', schools,
                            'school_name', 'school_address'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'User Statistics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.blueAccent,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                String school;
                                switch (group.x.toInt()) {
                                  case 0:
                                    school = 'School 1';
                                    break;
                                  case 1:
                                    school = 'School 2';
                                    break;
                                  case 2:
                                    school = 'School 3';
                                    break;
                                  case 3:
                                    school = 'School 4';
                                    break;
                                  default:
                                    school = '';
                                }
                                return BarTooltipItem(
                                  '$school\n${rod.toY.round()}',
                                  const TextStyle(color: Colors.white),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  const style = TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  );
                                  String text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = 'S1';
                                      break;
                                    case 1:
                                      text = 'S2';
                                      break;
                                    case 2:
                                      text = 'S3';
                                      break;
                                    case 3:
                                      text = 'S4';
                                      break;
                                    default:
                                      text = '';
                                  }
                                  return Text(text, style: style);
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                                reservedSize: 28,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(toY: 8, color: Colors.blue)
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(toY: 10, color: Colors.blue)
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(toY: 14, color: Colors.blue)
                              ],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(toY: 15, color: Colors.blue)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.43,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
