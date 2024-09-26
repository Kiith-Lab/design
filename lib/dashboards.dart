import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'config.dart';

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
  List<dynamic> folders = [];
  int userCount = 0;
  List<dynamic> users = [];
  int schoolCount = 0;
  List<dynamic> schools = [];
  int instructorCount = 0;
  List<dynamic> instructors = [];
  final String _searchQuery = '';
  final String _sortOrder = 'all';
  final String _schoolFilter = 'all';
  final String _departmentFilter = 'all';

  @override
  void initState() {
    super.initState();
    fetchFolders();
    fetchUsers();
    fetchSchools();
    fetchInstructors();
  }

  Future<void> fetchFolders() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}view.php'),
        body: {'operation': 'getFolders'},
      );

      if (response.statusCode == 200) {
        final dynamic decodedResponse = json.decode(response.body);
        List<dynamic> fetchedFolders;

        if (decodedResponse is Map) {
          if (decodedResponse.containsKey('error')) {
            print('Error from server: ${decodedResponse['error']}');
            return;
          }
          fetchedFolders = decodedResponse.values.toList();
        } else if (decodedResponse is List) {
          fetchedFolders = decodedResponse;
        } else {
          print('Unexpected response format');
          return;
        }

        setState(() {
          folders = fetchedFolders;
          projectCount = folders.length;
        });
      } else {
        print('Failed to fetch folders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching folders: $e');
    }
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}view.php'),
        body: {'operation': 'getUser'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedUsers = json.decode(response.body);
        setState(() {
          users = fetchedUsers;
          userCount = users.length;
        });
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
        Uri.parse('${baseUrl}view.php'),
        body: {'operation': 'getSchool'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedSchools = json.decode(response.body);
        setState(() {
          schools = fetchedSchools;
          schoolCount = schools.length;
        });
      } else {
        print('Failed to fetch schools: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schools: $e');
    }
  }

  Future<void> fetchInstructors() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}view.php'),
        body: {'operation': 'getInstructors'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedInstructors = json.decode(response.body);
        setState(() {
          instructors = fetchedInstructors
              .where((instructor) => instructor['role_name'] != 'Admin')
              .toList();
          instructorCount = instructors.length;
        });
      } else {
        print('Failed to fetch instructors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching instructors: $e');
    }
  }

  void _showList(BuildContext context, String title, List<dynamic> items,
      String nameKey, String descriptionKey) {
    String localSearchQuery = '';
    String localSortOrder = 'all';
    String localSchoolFilter = 'all';
    String localDepartmentFilter = 'all';
    bool hideFilters =
        title == 'Schools' || title == 'User Accounts' || title == 'Folders';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            List<dynamic> filteredItems = items.where((item) {
              final name = item[nameKey]?.toString().toLowerCase() ?? '';
              final description =
                  item[descriptionKey]?.toString().toLowerCase() ?? '';
              final schoolName =
                  item['school_name']?.toString().toLowerCase() ?? '';
              final departmentName =
                  item['department_name']?.toString().toLowerCase() ?? '';

              bool matchesSearch =
                  name.contains(localSearchQuery.toLowerCase()) ||
                      description.contains(localSearchQuery.toLowerCase()) ||
                      schoolName.contains(localSearchQuery.toLowerCase()) ||
                      departmentName.contains(localSearchQuery.toLowerCase());

              bool matchesSchool = localSchoolFilter == 'all' ||
                  schoolName == localSchoolFilter.toLowerCase();
              bool matchesDepartment = localDepartmentFilter == 'all' ||
                  departmentName == localDepartmentFilter.toLowerCase();

              return matchesSearch &&
                  (hideFilters || (matchesSchool && matchesDepartment));
            }).toList();

            filteredItems.sort((a, b) {
              final aName = a[nameKey]?.toString().toLowerCase() ?? '';
              final bName = b[nameKey]?.toString().toLowerCase() ?? '';
              if (localSortOrder == 'asc') {
                return aName.compareTo(bName);
              } else if (localSortOrder == 'desc') {
                return bName.compareTo(aName);
              }
              return 0;
            });

            List<String> schoolNames = [
              'all',
              ...items
                  .map((item) => item['school_name']?.toString() ?? '')
                  .where((name) => name.isNotEmpty)
                  .toSet()
            ];

            List<String> departmentNames = [
              'all',
              ...items
                  .map((item) => item['department_name']?.toString() ?? '')
                  .where((name) => name.isNotEmpty)
                  .toSet()
            ];

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search $title...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.teal),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.sort, color: Colors.teal),
                              onSelected: (String value) {
                                setDialogState(() {
                                  localSortOrder = value;
                                });
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'all',
                                  child: Text('All'),
                                ),
                                const PopupMenuItem(
                                  value: 'asc',
                                  child: Text('A-Z'),
                                ),
                                const PopupMenuItem(
                                  value: 'desc',
                                  child: Text('Z-A'),
                                ),
                              ],
                            ),
                            if (!hideFilters)
                              IconButton(
                                icon: const Icon(Icons.filter_list,
                                    color: Colors.teal),
                                onPressed: () => _showFilterDialog(
                                  context,
                                  (newSchoolFilter, newDepartmentFilter) {
                                    setDialogState(() {
                                      localSchoolFilter = newSchoolFilter;
                                      localDepartmentFilter =
                                          newDepartmentFilter;
                                    });
                                  },
                                  localSchoolFilter,
                                  localDepartmentFilter,
                                  schoolNames,
                                  departmentNames,
                                  hideFilters,
                                ),
                              ),
                          ],
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          localSearchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final usersName = item['users_firstname'];
                          final role = item['role_name'];
                          final projectTitle = item['Lesson'];
                          final schoolName = item['school_name'];
                          final departmentName = item['department_name'];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Text(
                                  usersName?.isNotEmpty ?? false
                                      ? usersName![0].toUpperCase()
                                      : 'N',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                usersName ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (role != null)
                                    Text(
                                      role,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (projectTitle != null)
                                    Text(
                                      projectTitle,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (title != 'Instructors' &&
                                      schoolName != null)
                                    Text(
                                      schoolName,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (title == 'Schools' &&
                                      departmentName != null)
                                    Text(
                                      departmentName,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                if (title == 'Folders') {
                                  _showFolderDetails(context, item);
                                } else if (title == 'Schools') {
                                  _showDepartmentDetails(context, item);
                                }
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

  void _showFolderDetails(BuildContext context, dynamic folder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Folder Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFolderDetail('Mode', folder['Mode'] ?? 'N/A'),
              _buildFolderDetail(
                  'Duration', folder['Duration']?.toString() ?? 'N/A'),
              _buildFolderDetail('Activity', folder['Activity'] ?? 'N/A'),
              _buildFolderDetail('Lesson', folder['Lesson'] ?? 'N/A'),
              _buildFolderDetail('Output', folder['Output'] ?? 'N/A'),
              _buildFolderDetail('Instruction', folder['Instruction'] ?? 'N/A'),
              _buildFolderDetail(
                  'Coach Detail', folder['CoachDetail'] ?? 'N/A'),
              ElevatedButton(
                child: const Text('Print PDF'),
                onPressed: () => _printFolderDetailsPDF(folder),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _printFolderDetailsPDF(dynamic folder) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Folder Details',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Field',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Value',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                _buildPDFTableRow('Mode', folder['Mode'] ?? 'N/A'),
                _buildPDFTableRow(
                    'Duration', folder['Duration']?.toString() ?? 'N/A'),
                _buildPDFTableRow('Activity', folder['Activity'] ?? 'N/A'),
                _buildPDFTableRow('Lesson', folder['Lesson'] ?? 'N/A'),
                _buildPDFTableRow('Output', folder['Output'] ?? 'N/A'),
                _buildPDFTableRow(
                    'Instruction', folder['Instruction'] ?? 'N/A'),
                _buildPDFTableRow(
                    'Coach Detail', folder['CoachDetail'] ?? 'N/A'),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.TableRow _buildPDFTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(value),
        ),
      ],
    );
  }

  Widget _buildFolderDetail(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }

  void _showDepartmentDetails(BuildContext context, dynamic school) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Department Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDepartmentDetail(
                  'Department Name', school['department_name'] ?? 'N/A'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepartmentDetail(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }

  void _showFilterDialog(
      BuildContext context,
      Function(String, String) onFilterApplied,
      String localSchoolFilter,
      String localDepartmentFilter,
      List<String> schoolNames,
      List<String> departmentNames,
      bool hideFilters) {
    String tempSchoolFilter = localSchoolFilter;
    String tempDepartmentFilter = localDepartmentFilter;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Filter'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hideFilters)
                      _buildDropdown('School', tempSchoolFilter, schoolNames,
                          (String? newValue) {
                        setState(() {
                          tempSchoolFilter = newValue!;
                        });
                      }),
                    if (!hideFilters) const SizedBox(height: 16),
                    _buildDropdown(
                        'Department', tempDepartmentFilter, departmentNames,
                        (String? newValue) {
                      setState(() {
                        tempDepartmentFilter = newValue!;
                      });
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                    onFilterApplied(tempSchoolFilter, tempDepartmentFilter);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButton<String>(
          isExpanded: true,
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value == 'all' ? 'All $label' : value),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Design_Thinking_Admin.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 32),
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
                      'Folders',
                      projectCount.toString(),
                      Icons.folder,
                      Colors.orange,
                      () => _showList(context, 'Folders', folders,
                          'project_title', 'users_firstname'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard(
                      'Instructors',
                      instructorCount.toString(),
                      FontAwesomeIcons.userPlus,
                      Colors.purple,
                      () => _showList(context, 'Instructors', instructors,
                          'users_firstname', 'role_name'),
                    ),
                    _buildInfoCard(
                      'Schools',
                      schoolCount.toString(),
                      FontAwesomeIcons.school,
                      Colors.green,
                      () => _showList(context, 'Schools', schools,
                          'school_name', 'school_address'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'User Statistics',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String school = 'School ${group.x.toInt() + 1}';
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
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  'S${value.toInt() + 1}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
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
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 6),
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
