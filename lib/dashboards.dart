import 'dart:convert';
import 'dart:html' as html; // Add this import for web file handling
import 'dart:io';

import 'package:excel_dart/excel_dart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
  int departmentCount = 0;
  List<dynamic> schools = [];
  List<dynamic> departments = [];
  int instructorCount = 0;
  List<dynamic> instructors = [];
  final String _searchQuery = '';
  final String _sortOrder = 'all';
  final String _schoolFilter = 'all';
  final String _departmentFilter = 'all';

  bool _isDialogOpen = false;

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

  Future<void> fetchDepartment() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}view.php'),
        body: {'operation': 'getDepartments'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedDepartments = json.decode(response.body);

        setState(() {
          departments = fetchedDepartments;
          departmentCount = departments.length;
        });
      } else {
        print('Failed to fetch departments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching departments: $e');
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

  Future<void> _updateUserStatus(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}update.php'), // Update with your actual endpoint
        body: {
          'users_id': userId.toString(),
          'operation': 'updateUser'
          // 'users_status': '0'
        }, // Adjust the body as needed
      );

      if (response.statusCode == 200) {
        // Handle successful response
        print('User status updated successfully');
        fetchUsers();
      } else {
        print('Failed to update user status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user status: $e');
    }
  }

  void _showConfirmationDialog(BuildContext context, int usersId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deactivation'),
          content: const Text('Are you sure you want to deactivate this user?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                _updateUserStatus(usersId); // Call the deactivation function
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showList(BuildContext context, String title, List<dynamic> items,
      String nameKey, String descriptionKey) {
    String localSearchQuery = '';
    String localSortOrder = 'all';
    String localSchoolFilter = 'all';
    String localDepartmentFilter = 'all';
    bool hideFilters =
        title == 'Schools' || title == 'User Accounts' || title == 'Folders';

    if (title == 'Schools') {
      fetchDepartment(); // Fetch departments when the Schools card is clicked
    }

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
              insetPadding:
                  EdgeInsets.zero, // Removes any padding around the dialog
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
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
                          borderRadius: BorderRadius.circular(10),
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
                          final mode = item['Mode'];
                          final schoolName = item['school_name'];
                          final schoolPlace = item['school_country'];
                          final departmentName = item['department_name'];

                          // Check if the user status is 1 only if the title is not 'Schools'
                          if (title != 'Schools' &&
                              title != 'Folders' &&
                              item['users_status'] != 1) {
                            return SizedBox
                                .shrink(); // Skip this item if status is not 1
                          }

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.teal,
                                    child: Text(
                                      usersName?.isNotEmpty ?? false
                                          ? usersName![0].toUpperCase()
                                          : 'N', // Use 'N' for empty or null names
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    usersName ??
                                        projectTitle ??
                                        schoolName ??
                                        'No Name',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          mode,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      // Always show school name if title is not 'Instructors'
                                      if (title != 'Instructors' &&
                                          schoolName != null)
                                        Text(
                                          schoolName.isNotEmpty
                                              ? schoolPlace
                                              : 'No School',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      // Show department name only for Schools
                                      if (title == 'Schools' &&
                                          departmentName != null)
                                        Text(
                                          departmentName.isNotEmpty
                                              ? departmentName
                                              : 'No Department',
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
                                // Only show the delete button in 'User Accounts'
                                if (title == 'User Accounts')
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () {
                                        _showConfirmationDialog(
                                            context, item['users_id']);
                                      },
                                    ),
                                  ),
                              ],
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
        return Dialog(
          insetPadding: EdgeInsets.zero, // Makes it fullscreen
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16), // Optional, for rounded corners
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Folder Details',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      // Display folder details without array
                      _buildFolderDetail('Mode', folder['Mode'] ?? 'N/A'),
                      _buildFolderDetail(
                          'Duration', folder['Duration']?.toString() ?? 'N/A'),
                      _buildFolderDetail(
                          'Activity', folder['Activity'] ?? 'N/A'),
                      _buildFolderDetail('Lesson', folder['Lesson'] ?? 'N/A'),
                      _buildFolderDetail('Output', folder['Output'] ?? 'N/A'),
                      _buildFolderDetail(
                          'Instruction', folder['Instruction'] ?? 'N/A'),
                      _buildFolderDetail(
                          'Coach Detail', folder['CoachDetail'] ?? 'N/A'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ShadButton(
                            child: const Text('Print PDF'),
                            onPressed: () => _printFolderDetailsPDF(folder),
                          ),
                          ShadButton(
                            onPressed: () =>
                                _exportFolderDetailsExcel(context, folder),
                            child: const Text('Export Excel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                // Removed array and replaced with individual calls
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

    if (kIsWeb) {
      // For web, create a Blob and download the PDF
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'folder_details.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile/desktop, use the existing printing method
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
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

  Future<void> _exportFolderDetailsExcel(
      BuildContext context, dynamic folder) async {
    // Create a new Excel document
    final Excel excel = Excel.createExcel(); // Create a new Excel document
    Sheet sheet = excel['Sheet1']; // Create a new sheet

    // Add headers
    sheet.appendRow(['Field', '', 'Notes/Remarks']);

    // Add folder details
    List<String> fields = [
      'Mode',
      'Duration',
      'Activity',
      'Lesson',
      'Output',
      'Instruction',
      'CoachDetail'
    ];

    for (String field in fields) {
      sheet
          .appendRow([field, folder[field] ?? 'N/A', '']); // Add folder details
    }

    // Check if running on the web
    if (kIsWeb) {
      // Convert the Excel file to bytes
      final bytes = excel.encode();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'folder_details.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Get the directory for saving the Excel file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/folder_details.xlsx';
      final file = File(filePath);
      // Save the Excel file
      await file.writeAsBytes(excel.encode()!, flush: true);

      // Provide feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel file saved to $filePath')),
      );
    }
  }

  Widget _buildFolderDetail(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }

  void _showDepartmentDetails(BuildContext context, dynamic school) {
    if (_isDialogOpen)
      return; // Prevent opening a new dialog if one is already open
    _isDialogOpen = true; // Set the flag to true when opening the dialog

    fetchDepartment().then((_) {
      if (departments.isNotEmpty) {
        // Check if departments are available
        showDialog(
          context: context,
          builder: (BuildContext context) {
            String departmentSearchQuery = '';
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                List<dynamic> filteredDepartments =
                    departments.where((department) {
                  final departmentName =
                      department['department_name']?.toString().toLowerCase() ??
                          '';
                  return departmentName
                      .contains(departmentSearchQuery.toLowerCase());
                }).toList();

                return Dialog(
                  insetPadding: EdgeInsets.zero, // Remove default padding
                  child: SizedBox(
                    width:
                        MediaQuery.of(context).size.width, // Full screen width
                    height: MediaQuery.of(context)
                        .size
                        .height, // Full screen height
                    child: Column(
                      children: [
                        AppBar(
                          title: const Text('Department Details'),
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.teal,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _isDialogOpen = false;
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search Departments...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.teal),
                            ),
                            onChanged: (value) {
                              setState(() {
                                departmentSearchQuery = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredDepartments.length,
                            itemBuilder: (context, index) {
                              final department = filteredDepartments[index];
                              return GestureDetector(
                                onTap: () async {
                                  final departmentName =
                                      department['department_name'];
                                  final schoolname = school['school_name'];

                                  final jsondata = jsonEncode({
                                    'schoolname': schoolname,
                                    'departmentname': departmentName,
                                  });

                                  final response = await http.post(
                                    Uri.parse('${baseUrl}view.php'),
                                    body: {
                                      "json": jsondata,
                                      "operation": "getUsers"
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    final dynamic decodedResponse =
                                        json.decode(response.body);
                                    if (decodedResponse is List) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          String userSearchQuery = '';
                                          return StatefulBuilder(
                                            builder: (BuildContext context,
                                                StateSetter setState) {
                                              List<dynamic> filteredUsers =
                                                  decodedResponse.where((user) {
                                                final userName =
                                                    user['users_firstname']
                                                            ?.toString()
                                                            .toLowerCase() ??
                                                        '';
                                                return userName.contains(
                                                    userSearchQuery
                                                        .toLowerCase());
                                              }).toList();

                                              return Dialog(
                                                insetPadding: EdgeInsets.zero,
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  child: Column(
                                                    children: [
                                                      AppBar(
                                                        title: Text(
                                                          '$departmentName',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.teal,
                                                        actions: [
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.close),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: TextField(
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'Search Users...',
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                            ),
                                                            filled: true,
                                                            fillColor: Colors
                                                                .grey[200],
                                                            prefixIcon:
                                                                const Icon(
                                                                    Icons
                                                                        .search,
                                                                    color: Colors
                                                                        .teal),
                                                          ),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              userSearchQuery =
                                                                  value;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          itemCount:
                                                              filteredUsers
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final user =
                                                                filteredUsers[
                                                                    index];

                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          5,
                                                                      horizontal:
                                                                          10),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .blue
                                                                    .shade50,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            3),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ListTile(
                                                                onTap:
                                                                    () async {
                                                                  final usersId =
                                                                      user[
                                                                          'users_id'];

                                                                  final jsondata =
                                                                      jsonEncode({
                                                                    'users_id':
                                                                        usersId,
                                                                  });

                                                                  final projectResponse =
                                                                      await http
                                                                          .post(
                                                                    Uri.parse(
                                                                        '${baseUrl}view.php'),
                                                                    body: {
                                                                      "json":
                                                                          jsondata,
                                                                      "operation":
                                                                          "getFolderId",
                                                                    },
                                                                  );

                                                                  if (projectResponse
                                                                          .statusCode ==
                                                                      200) {
                                                                    final projectData =
                                                                        json.decode(
                                                                            projectResponse.body);
                                                                    if (projectData
                                                                        is List) {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return Dialog(
                                                                            insetPadding:
                                                                                EdgeInsets.zero,
                                                                            child:
                                                                                SizedBox(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: MediaQuery.of(context).size.height,
                                                                              child: Column(
                                                                                children: [
                                                                                  AppBar(
                                                                                    title: Text(
                                                                                      '${user['users_firstname'] ?? 'N/A'} ${user['users_lastname'] ?? 'N/A'}',
                                                                                      style: const TextStyle(
                                                                                        fontSize: 18,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        color: Colors.greenAccent,
                                                                                      ),
                                                                                    ),
                                                                                    backgroundColor: Colors.teal,
                                                                                    actions: [
                                                                                      IconButton(
                                                                                        icon: const Icon(Icons.picture_as_pdf_rounded),
                                                                                        onPressed: () {
                                                                                          _printAllLessonsPDF(projectData); // New function to print all lessons
                                                                                        },
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: ListView.builder(
                                                                                      itemCount: projectData.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        final project = projectData[index];

                                                                                        return GestureDetector(
                                                                                          onTap: () {
                                                                                            _showFolderDetails(context, project);
                                                                                          },
                                                                                          child: Container(
                                                                                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                                                            padding: const EdgeInsets.all(16),
                                                                                            decoration: BoxDecoration(
                                                                                              color: Colors.white,
                                                                                              borderRadius: BorderRadius.circular(12),
                                                                                              boxShadow: [
                                                                                                BoxShadow(
                                                                                                  color: Colors.grey.withOpacity(0.5),
                                                                                                  spreadRadius: 2,
                                                                                                  blurRadius: 5,
                                                                                                  offset: const Offset(0, 3),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Text(
                                                                                                  project['Lesson'] ?? 'N/A',
                                                                                                  style: const TextStyle(
                                                                                                    fontSize: 16,
                                                                                                    color: Colors.black,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                  ),
                                                                                                ),
                                                                                                const Icon(
                                                                                                  Icons.arrow_forward_ios,
                                                                                                  size: 18,
                                                                                                  color: Colors.grey,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  }
                                                                },
                                                                title: Text(
                                                                  '${user['users_lastname'] ?? 'N/A'}, ${user['users_firstname'] ?? 'N/A'}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black87,
                                                                  ),
                                                                ),
                                                                leading:
                                                                    const CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blueAccent,
                                                                  child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                trailing:
                                                                    const Icon(
                                                                  Icons
                                                                      .info_outline,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                ),
                                                              ),
                                                            );
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
                                  }
                                },
                                child: Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: SizedBox(
                                    height: 75,
                                    child: ListTile(
                                      leading: const Icon(Icons.group),
                                      title: Text(
                                        department['department_name'] ?? 'N/A',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: const Text('Tap to view users',
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                ),
                              );
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
        ).then((_) {
          _isDialogOpen = false;
        });
      } else {
        print('No departments available');
      }
    });
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
            padding: const EdgeInsets.all(24.0), // Overall padding
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Define breakpoints for responsiveness
                bool isWideScreen = constraints.maxWidth > 800;
                int crossAxisCount = isWideScreen ? 4 : 2;
                double childAspectRatio = isWideScreen ? 2 : 1.5;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 32),

                    // Info Cards Section
                    isWideScreen
                        ? GridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16, // Outer vertical spacing
                            crossAxisSpacing: 16, // Outer horizontal spacing
                            childAspectRatio: childAspectRatio,
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
                              _buildInfoCard(
                                'Instructors',
                                instructorCount.toString(),
                                FontAwesomeIcons.userPlus,
                                Colors.purple,
                                () => _showList(
                                    context,
                                    'Instructors',
                                    instructors,
                                    'users_firstname',
                                    'role_name'),
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
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0), // Half of SizedBox width
                                      child: _buildInfoCard(
                                        'User Accounts',
                                        users
                                            .where((user) =>
                                                user['users_status'] == 1)
                                            .length
                                            .toString(),
                                        Icons.person,
                                        Colors.blue,
                                        () => _showList(
                                            context,
                                            'User Accounts',
                                            users,
                                            'users_firstname',
                                            'role_name'),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0), // Half of SizedBox width
                                      child: _buildInfoCard(
                                        'Folders',
                                        projectCount.toString(),
                                        Icons.folder,
                                        Colors.orange,
                                        () => _showList(
                                            context,
                                            'Folders',
                                            folders,
                                            'project_title',
                                            'users_firstname'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 8.0), // Half of SizedBox width
                                      child: _buildInfoCard(
                                        'Instructors',
                                        instructors
                                            .where((instructor) =>
                                                instructor['users_status'] == 1)
                                            .length
                                            .toString(),
                                        FontAwesomeIcons.userPlus,
                                        Colors.purple,
                                        () => _showList(
                                            context,
                                            'Instructors',
                                            instructors,
                                            'users_firstname',
                                            'role_name'),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0), // Half of SizedBox width
                                      child: _buildInfoCard(
                                        'Schools',
                                        schoolCount.toString(),
                                        FontAwesomeIcons.school,
                                        Colors.green,
                                        () => _showList(
                                            context,
                                            'Schools',
                                            schools,
                                            'school_name',
                                            'school_address'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                    const SizedBox(height: 840),

                    // User Statistics Section
                  ],
                );
              },
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

  Future<void> _printAllLessonsPDF(List<dynamic> lessons) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('All Lessons',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Field')),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Value')),
                  ],
                ),
                ...lessons.map((lesson) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Mode')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(lesson['Mode']?.toString() ?? 'N/A')),
                    ],
                  );
                }).toList(),
                ...lessons.map((lesson) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Duration')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(lesson['Duration']?.toString() ?? 'N/A')),
                    ],
                  );
                }).toList(),
                ...lessons.map((lesson) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Activity')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(lesson['Activity']?.toString() ?? 'N/A')),
                    ],
                  );
                }).toList(),
                ...lessons.map((lesson) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Lesson')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(lesson['Lesson']?.toString() ?? 'N/A')),
                    ],
                  );
                }).toList(),
                ...lessons.map((lesson) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Output')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child:
                              pw.Text(lesson['Output']?.toString() ?? 'N/A')),
                    ],
                  );
                }).toList(),
                ...lessons.map((lesson) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Instruction')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              lesson['Instruction']?.toString() ?? 'N/A')),
                    ],
                  );
                }).toList(),
                ...lessons.map((lesson) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Coach Detail')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                              lesson['CoachDetail']?.toString() ?? 'N/A')),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );

    // ... existing PDF saving logic ...
    if (kIsWeb) {
      // For web, create a Blob and download the PDF
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'all_lessons.pdf') // Updated filename
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile/desktop, use the existing printing method
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  }
}
