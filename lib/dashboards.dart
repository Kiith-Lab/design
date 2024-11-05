import 'dart:convert';
import 'dart:html' as html; // Add this import for web file handling
import 'dart:io';

import 'package:excel_dart/excel_dart.dart';

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
  String data =
      "• Guide students to view testing as a cycle of continuous improvement, where each round of feedback refines their work toward a successful webpage. •Encourage trial and error by valuing experimentation, treating errors as learning opportunities, and providing safe scenarios for testing various solutions.      ,Provide clear, actionable feedback that highlights strengths, areas for improvement, and practical suggestions to help students enhance their work.";

  String result = separateText(data);
  print(result);
}

String separateText(String text) {
  // Split the text by bullet points and commas
  List<String> parts = text.split(RegExp(r'•|,'));

  // Trim whitespace and filter out empty strings
  List<String> separatedParts = parts
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  return separatedParts.join('\n• '); // Join with bullet points and new lines
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
  final dynamic folder; // Add this line

  const Dashboards({super.key, this.folder}); // Update constructor

  @override
  _DashboardsState createState() => _DashboardsState();
}

class _DashboardsState extends State<Dashboards> {
  List<Map<String, dynamic>>? cardData;
  List<Map<String, dynamic>>? moduleData;

  int projectCount = 0;
  String remarks = '';
  List<dynamic> folders = [];
  List<dynamic> foldersPDF = [];
  int userCount = 0;
  List<dynamic> users = [];
  int schoolCount = 0;
  int departmentCount = 0;
  List<dynamic> schools = [];
  List<dynamic> departments = [];
  int instructorCount = 0;
  List<dynamic> instructors = [];

  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    fetchFolders();
    fetchFoldersPDF();
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

  Future<void> _fetchCardData(String projectId) async {
    if (folders.isNotEmpty) {
      try {
        // Make the HTTP POST request to your API
        final response = await http.post(
          Uri.parse('${baseUrl}masterlist.php'),
          body: {
            'operation': 'getCards1',
            'projectId': projectId.toString(),
          },
        );

        // Check if the response status is OK (HTTP 200)
        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);

          // Check if the response is a map (expected JSON format)
          if (data is Map<String, dynamic>) {
            if (data['success'] == true && data['data'] != null) {
              setState(() {
                cardData = List<Map<String, dynamic>>.from(
                    data['data']); // Store multiple cards
              });
              print('Fetched Card Data:');
              cardData?.forEach((card) {
                print('Card Title: ${card['cards_title']}');
                print('Card Content: ${card['cards_content']}');
              });
            } else {
              print('No data found');
              setState(() {
                cardData = null;
              });
            }
          } else {
            // Handle unexpected data types
            print('Unexpected data format: ${data.runtimeType}');
            print('Data content: $data');
            setState(() {
              cardData = null;
            });
          }
        } else {
          // Log failure to fetch data with response details
          print('Failed to fetch card data');
          print('Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          setState(() {
            cardData = null;
          });
        }
      } catch (e) {
        // Handle and log exceptions
        print('Database error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database error occurred: $e')),
        );
      }
    }
  }

  Future<void> _fetchProject(String projectId) async {
    if (folders.isNotEmpty) {
      print('Fetching project data for projectId: $projectId');

      try {
        final response = await http.post(
          Uri.parse('${baseUrl}masterlist.php'),
          body: {
            'operation': 'getFolders',
            'projectId': projectId.toString(),
          },
        );

        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);

          if (data is Map<String, dynamic>) {
            if (data['success'] == true && data['folders'] != null) {
              setState(() {
                moduleData = List<Map<String, dynamic>>.from(data['folders']);
                // Extract and store IDs
                for (var module in moduleData!) {
                  print('Module ID: ${module['module_master_id']}');
                  print('Activity ID: ${module['activities_details_id']}');
                  // Add more IDs as needed
                }
              });
              print('Fetched Project Data:');
              moduleData?.forEach((module) {
                print('Module Name: ${module['module_master_name']}');
                print('Module Details: ${module['module_master_name']}');
              });
            } else {
              print('No data found or success flag is false');
              setState(() {
                moduleData = null;
              });
            }
          } else {
            print('Unexpected data format: ${data.runtimeType}');
            print('Data content: $data');
            setState(() {
              moduleData = null;
            });
          }
        } else {
          print('Failed to fetch project data');
          print('Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          setState(() {
            moduleData = null;
          });
        }
      } catch (e) {
        print('Database error occurred: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database error occurred: $e')),
        );
      }
    }
  }

  Future<void> fetchFoldersPDF() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}masterlist.php'),
        body: {'operation': 'getFolder'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['folders'] != null && data['folders'] is List) {
          setState(() {
            foldersPDF = List<Map<String, dynamic>>.from(data['folders']
                .map((item) => {
                      'folder_id': item['id'] ?? '',
                      'activity_id': item['activities_details_id'] ?? '',
                      'project_subject_code':
                          item['project_subject_code'] ?? '',
                      'project_subject_description':
                          item['project_subject_description'] ?? '',
                      'project_title': item['project_title'] ?? '',
                      'project_description': item['project_description'] ?? '',
                      'project_start_date': item['project_start_date'] ?? '',
                      'project_end_date': item['project_end_date'] ?? '',
                      'module_master_name': item['module_master_name'] ?? '',
                      'module_master_id': item['module_master_id'] ?? '',
                      'activities_details_content':
                          item['activities_details_content'] ?? '',
                      'activities_header_duration':
                          item['activities_header_duration'] ?? '',
                      'cards_title': item['cards_title'] ?? '',
                      'outputs_content': item['outputs_content'] ?? '',
                      'instruction_content': item['instruction_content'] ?? '',
                      'coach_detail_content':
                          item['coach_detail_content'] ?? '',
                      'project_cardsId': item['project_cardsId'] is List
                          ? item['project_cardsId']
                          : [],
                      'cards_content': item['cards_content'] ?? '',
                      'back_cards_header_title':
                          item['back_cards_header_title'] ?? '',
                      'back_content_title': item['back_content_title'] ?? '',
                      'back_content': item['back_content'] ?? '',
                      'projectId': item['projectId'] ?? '',
                      'back_cards_header_frontId':
                          item['back_cards_header_frontId'] ?? '',
                      'activities_details_remarks':
                          item['activities_details_remarks'] ?? '',
                      'coach_detail_renarks':
                          item['coach_detail_renarks'] ?? '',
                      'outputs_remarks': item['outputs_remarks'] ?? '',
                      'project_cards_remarks':
                          item['project_cards_renarks'] ?? '',
                      'instruction_remarks': item['instruction_remarks'] ?? '',
                      'coach_detail_id': item['coach_detail_id'] ?? '',
                      'instruction_id': item['instruction_id'] ?? '',
                      'output_id': item['outputs_id'] ?? '',
                    })
                .toList());
          });
        } else {
          print('Invalid data format. Response: ${response.body}');
          throw Exception('Invalid data format: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to load folders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching folders: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching folders: ${e.toString()}')),
      );
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Rounded corners
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.8, // Make dialog wider
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjusts height to content
              children: [
                // Title with enhanced style
                const Text(
                  'Confirm Deactivation',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // Spacing between title and content

                // Content with adjusted style and padding
                const Text(
                  'Are you sure you want to deactivate this user? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30), // Spacing before buttons

                // Buttons aligned horizontally
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel button with improved style
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400], // Grey background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 20.0,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),

                    // Confirm button with improved style
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent, // Red accent background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 20.0,
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                      onPressed: () {
                        _updateUserStatus(
                            usersId); // Call the deactivation function
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              final projectTitle =
                  item['project_title']?.toString().toLowerCase() ??
                      ''; // Ensure this line is included

              bool matchesSearch =
                  name.contains(localSearchQuery.toLowerCase()) ||
                      description.contains(localSearchQuery.toLowerCase()) ||
                      schoolName.contains(localSearchQuery.toLowerCase()) ||
                      departmentName.contains(localSearchQuery.toLowerCase()) ||
                      projectTitle.contains(
                          localSearchQuery.toLowerCase()); // Add this condition

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

            List<String> projectTitles = [
              'all',
              ...items
                  .map((item) => item['project_title']?.toString() ?? '')
                  .where((title) => title.isNotEmpty)
                  .toSet()
            ];

            return Dialog(
              insetPadding:
                  EdgeInsets.zero, // Removes any padding around the dialog
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22, // Adjust font size as needed
                        fontWeight:
                            FontWeight.bold, // Adjust font weight as needed
                        color: Colors.white, // Set text color if needed
                      ),
                    ),
                    backgroundColor:
                        Colors.green, // Set the AppBar color to green
                    automaticallyImplyLeading:
                        false, // Remove the default back button
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Remove the title Text widget since it's now in the AppBar

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
                                  const Icon(Icons.search, color: Colors.green),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.sort,
                                        color: Colors.green),
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
                                          color: Colors.green),
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
                                        projectTitles,
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
                                  return const SizedBox
                                      .shrink(); // Skip this item if status is not 1
                                }

                                return Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.green,
                                          child: Text(
                                            usersName?.isNotEmpty ?? false
                                                ? usersName![0].toUpperCase()
                                                : 'N', // Use 'N' for empty or null names
                                            style: const TextStyle(
                                                color: Colors.white),
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
                                              )
                                          ],
                                        ),
                                        onTap: () {
                                          if (title == 'Folders') {
                                            _showFolderDetails(context, item);
                                          } else if (title == 'Schools') {
                                            _showDepartmentDetails(
                                                context, item);
                                          }
                                        },
                                      ),
                                      // Only show the delete button in 'User Accounts'
                                      if (title == 'User Accounts')
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: const Icon(
                                                Icons.archive_outlined,
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFolderDetails(BuildContext context, dynamic folder) {
    // Find the matching item in foldersPDF using "Lesson" and "project_title"
    var matchingPDF = foldersPDF.cast<Map<String, dynamic>>().firstWhere(
          (pdf) => pdf['project_title'] == folder['Lesson'],
          orElse: () => {}, // Default to an empty map if no match
        );

    var matchingExcel = foldersPDF.cast<Map<String, dynamic>>().firstWhere(
          (pdf) => pdf['project_title'] == folder['Lesson'],
          orElse: () => {}, // Default to an empty map if no match
        );

    // Check if matchingPDF is actually a match
    bool isMatchFound = matchingPDF.isNotEmpty;
    bool isMatchFounds = matchingExcel.isNotEmpty;

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
                const Text(
                  'Folder Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      // Display folder details with a custom card design
                      _buildCustomFolderDetail(
                        'Module',
                        _formatAsBulletList(folder['Mode'], useBullets: false),
                      ),
                      _buildCustomFolderDetail(
                        'How long will this activity take?',
                        _formatAsBulletList(
                            folder['Duration'] ?? 'No duration available',
                            useBullets: false),
                      ),
                      _buildCustomFolderDetail(
                        'Activity',
                        _formatAsBulletList(folder['Activity']),
                      ),
                      _buildCustomFolderDetail(
                        'Lesson',
                        folder['Lesson'] ?? 'N/A',
                      ),
                      _buildCustomFolderDetail(
                        'Output',
                        _formatAsBulletList(folder['Output']),
                      ),
                      _buildCustomFolderDetail(
                        'Instruction',
                        _formatAsBulletList(folder['Instruction']),
                      ),
                      _buildCustomFolderDetail(
                        'Coach Detail',
                        _formatAsBulletList(folder['CoachDetail']),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ShadButton(
                            child: const Text('Print PDF'),
                            onPressed: isMatchFound
                                ? () async {
                                    final projectId =
                                        matchingPDF['projectId'] ??
                                            matchingPDF['project_id'];
                                    if (projectId != null) {
                                      await _fetchProject(projectId.toString());
                                      await _fetchCardData(
                                          projectId.toString());
                                      if (mounted) {
                                        _printFolderDetailsPDF(
                                            context, matchingPDF);
                                      }
                                    } else {
                                      print("Project ID not found");
                                    }
                                  }
                                : null, // Disable if no match
                          ),
                          ShadButton(
                            child: const Text('Export Excel'),
                            onPressed: isMatchFounds
                                ? () async {
                                    final projectId =
                                        matchingExcel['projectId'] ??
                                            matchingExcel['project_id'];
                                    if (projectId != null) {
                                      await _fetchProject(projectId.toString());
                                      await _fetchCardData(
                                          projectId.toString());
                                      await _generateExcelWithModules(
                                          matchingExcel);
                                    } else {
                                      print("Project ID not found");
                                    }
                                  }
                                : null, // Disable if no match
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

  Widget _buildCustomFolderDetail(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatListToString(dynamic field) {
    // Debugging: Print the field type and content
    print('Field type: ${field.runtimeType}, Field content: $field');

    if (field is String) {
      // Check if the string is in valid JSON format
      if (field.startsWith('[') && field.endsWith(']')) {
        try {
          final dynamic parsedField = json.decode(field);
          if (parsedField is List) {
            return parsedField.join(' '); // Join with spaces
          }
        } catch (e) {
          print('Error parsing field as JSON: $e');
        }
      }
      // If not valid JSON, return the string directly
      return field; // Return the original string if it's not JSON
    } else if (field is List) {
      return field.join(' '); // Join with spaces
    }
    return field?.toString() ?? 'N/A';
  }

  // Helper function to format data in bullet form with new lines
  String _filterData(String? data) {
    if (data == null) {
      return '';
    }
    // Remove the array-like format and split into individual items
    List<String> items = data.replaceAll(RegExp(r'^\["|"\]$'), '').split('","');

    // Prepend a bullet point to each item and join them with new lines
    return items
        .map((item) => '- $item')
        .join('\n\n'); // Added extra \n for 1.5 spacing
  }

  Future<void> _printFolderDetailsPDF(
      BuildContext context, dynamic foldersPDF) async {
    final pdf = pw.Document();

    // Add the cover page with project details
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Center(
                  child: pw.Text('MY DESIGN THINKING PLAN',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  _buildPdfTableRow(
                      'Project', foldersPDF['project_title'], null),
                  _buildPdfTableRow('Project Description',
                      foldersPDF['project_subject_description'], null),
                  _buildPdfTableRow(
                      'Start Date', foldersPDF['project_start_date'], null),
                  _buildPdfTableRow(
                      'End Date', foldersPDF['project_end_date'], null),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Add each module on a separate page
    for (var module in moduleData ?? []) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Module Title
                pw.Text(
                  module['module_master_name'] ?? '',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),

                // Module Content Table
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Field',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Details',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Remarks',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Activities
                    _buildPdfTableRow(
                      'What activities will my students do?',
                      _filterData(module['activities_details_content']),
                      _filterData(module['activities_details_remarks']),
                    ),
                    // Method Cards
                    _buildPdfTableRow(
                      'What two (2) method cards will my students use?',
                      cardData
                          ?.where((card) =>
                              card['project_moduleId'] ==
                              module['project_moduleId'])
                          .map((card) => '- ${card['cards_title']}')
                          .join('\n'),
                      _filterData(foldersPDF['project_cards_remarks']),
                    ),
                    // Duration
                    _buildPdfTableRow(
                      'How long will this activity take?',
                      _filterData(module['activities_header_duration']),
                      null,
                    ),
                    // Outputs
                    _buildPdfTableRow(
                      'What are the expected outputs?',
                      _filterData(module['outputs_content']),
                      _filterData(module['outputs_remarks']),
                    ),
                    // Instructions
                    _buildPdfTableRow(
                      'What instructions will I give my students?',
                      _filterData(module['instruction_content']),
                      _filterData(module['instruction_remarks']),
                    ),
                    // Coaching
                    _buildPdfTableRow(
                      'How can I coach my students while doing this activity?',
                      _filterData(module['coach_detail_content']),
                      _filterData(module['coach_detail_renarks']),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    try {
      if (kIsWeb) {
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download',
              '${foldersPDF['project_title'] ?? 'project'}_details.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  // Helper method for building PDF table rows
  pw.TableRow _buildPdfTableRow(
      String field, String? content, String? remarks) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(field),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            content ?? 'Not specified',
            style: const pw.TextStyle(
              lineSpacing: 1.5, // Line spacing for content
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            remarks ?? '-',
            style: const pw.TextStyle(
              lineSpacing: 1.5, // Line spacing for remarks
            ),
          ),
        ),
      ],
    );
  }

  String _cleanText(String text) {
    // Remove newline characters, tabs, and backslashes
    return text.replaceAll(RegExp(r'[\n\t\\]'), '').trim();
  }

  pw.Widget _buildMultiLineRichText(String text) {
    // Split the text by newline character
    final lines = text.split('\n').map(_cleanText).toList();

    return pw.RichText(
      text: pw.TextSpan(
        children: lines.map((line) {
          return pw.TextSpan(
            text: line + '\n', // Add new line after each text span
            style: pw.TextStyle(fontSize: 12), // Optionally set a font size
          );
        }).toList(),
      ),
    );
  }

// This function formats the data for bullet points
  String _formatAsBulletList(dynamic value, {bool useBullets = true}) {
    if (value == null) return 'N/A';

    // If it's a string that looks like an array, parse it manually
    if (value is String) {
      // Remove square brackets and split the string by commas
      List<String> items = value.split(RegExp(r'\], \['));

      List<String> formattedList = items.map((item) {
        // Clean up each item, remove extra characters (including quotes)
        String cleanItem =
            _cleanText(item.replaceAll(RegExp(r'[\[\]"]'), '').trim());
        return useBullets ? '• $cleanItem' : cleanItem;
      }).toList();

      // Join items with newline if using bullets, otherwise with commas
      return formattedList.join(useBullets ? '\n' : ', ');
    }

    return _cleanText(
        value.toString()); // Clean the original value if not a string
  }

  List<String> _formatAsRowsForExcel(dynamic value) {
    if (value == null) return ['N/A'];

    // If it's a string that looks like an array, parse it manually
    if (value is String) {
      // Remove square brackets and split the string by commas
      List<String> items = value.split(RegExp(r'\], \['));

      List<String> formattedList = items.map((item) {
        // Clean up each item: remove extra characters (including quotes), backslashes, and newlines
        String cleanItem = item
            .replaceAll(
                RegExp(r'[\[\]"]'), '') // Remove square brackets and quotes
            .replaceAll(r'\', '') // Remove backslashes
            .replaceAll(r'\n', ' ') // Replace newlines with space
            .replaceAll(r'\t', ' ') // Replace tabs with space

            .trim();
        return cleanItem; // No need for bullet points for Excel rows
      }).toList();

      return formattedList; // Return list of cleaned-up items
    }

    return [value.toString()]; // Fallback to original behavior if not a string
  }

// Function to create Excel file
  Future<void> _generateExcelWithModules(
      Map<String, dynamic> matchingExcel) async {
    // Ensure foldersPDF is populated
    if (foldersPDF.isEmpty) {
      await fetchFoldersPDF();
    }

    final Excel excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.setColWidth(0, 50);
    sheet.setColWidth(1, 110);
    sheet.setColWidth(2, 40);

    sheet.appendRow(['', 'MY DESIGN THINKING PLAN']);

    final Set<String> processedProjects = {};

    // Filter foldersPDF to only include the selected project
    final selectedProjectId =
        matchingExcel['projectId'] ?? matchingExcel['project_id'];
    final selectedFolders = foldersPDF
        .where((folder) => folder['projectId'] == selectedProjectId)
        .toList();

    for (var folder in selectedFolders) {
      final projectTitle =
          folder['project_title']?.toString() ?? 'Unnamed Project';

      if (processedProjects.contains(projectTitle)) {
        continue;
      }

      processedProjects.add(projectTitle);

      sheet.appendRow(['Project', projectTitle, '']);
      sheet.appendRow([
        'Project Description',
        folder['project_subject_description']?.toString() ?? '',
        ''
      ]);
      sheet.appendRow([
        'Start Date',
        folder['project_start_date']?.toString() ?? 'No start date',
        ''
      ]);
      sheet.appendRow([
        'End Date',
        folder['project_end_date']?.toString() ?? 'No end date',
        ''
      ]);
      sheet.appendRow(['']);

      final Set<String> processedModules = {};

      for (var module in moduleData ?? []) {
        final moduleId = module['project_moduleId']?.toString() ?? '';

        if (processedModules.contains(moduleId)) {
          continue;
        }

        processedModules.add(moduleId);

        // Determine the color based on the module name
        final String moduleName =
            module['module_master_name']?.toString() ?? 'Unnamed Module';
        final String moduleColorHex;

        switch (moduleName) {
          case 'Empathize':
            moduleColorHex = '#6fa8dc'; // Blue
            break;
          case 'Define':
            moduleColorHex = '#38761d'; // Green
            break;
          case 'Ideate':
            moduleColorHex = '#ff9900'; // Orange
            break;
          case 'Prototype':
            moduleColorHex = '#f14309'; // Dark Red
            break;
          case 'Test':
            moduleColorHex = '#990000'; // Red
            break;
          default:
            moduleColorHex = '#000000'; // Default to black if no match
        }

        // Append the row with the module name
        sheet.appendRow([moduleName, '', 'NOTE/REMARKS']);

        // Apply the color to the last row's first cell
        final lastRowIndex = sheet.maxRows - 1;
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: lastRowIndex));
        cell.cellStyle = CellStyle(
          backgroundColorHex: moduleColorHex,
        );
        final centerCell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: lastRowIndex));
        centerCell.cellStyle = CellStyle(
          backgroundColorHex: moduleColorHex,
        );

        // Apply the same color to the "NOTE/REMARKS" cell
        final remarksCell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: lastRowIndex));
        remarksCell.cellStyle = CellStyle(
          backgroundColorHex: moduleColorHex,
        );

        // Append each bullet point as a separate row
        _appendBulletRows(
            sheet,
            'What activities will my students do?',
            _formatAsRowsForExcel(module['activities_details_content']),
            _formatAsRowsForExcel(module['activities_details_remarks']));

        _appendBulletRows(
            sheet,
            'What two (2) method cards will my students use?',
            cardData
                    ?.where((card) =>
                        card['project_moduleId']?.toString() == moduleId)
                    .map((card) => card['cards_title']?.toString())
                    .whereType<String>() // Filter out null values
                    .toList() ??
                ['N/A'],
            [folder['project_cards_remarks']?.toString() ?? 'No remarks']);

        _appendBulletRows(
            sheet,
            'How long will this activity take?',
            _formatAsRowsForExcel(module['activities_header_duration']),
            ['No remarks']);

        _appendBulletRows(
            sheet,
            'What are the expected outputs?',
            _formatAsRowsForExcel(module['outputs_content']),
            _formatAsRowsForExcel(module['outputs_remarks']));

        _appendBulletRows(
            sheet,
            'What instructions will I give my students?',
            _formatAsRowsForExcel(module['instruction_content']),
            _formatAsRowsForExcel(module['instruction_remarks']));

        _appendBulletRows(
            sheet,
            'How can I coach my students while doing this activity?',
            _formatAsRowsForExcel(module['coach_detail_content']),
            _formatAsRowsForExcel(module['coach_detail_renarks']));

        sheet.appendRow(['']);
      }
    }

    try {
      if (kIsWeb) {
        final bytes = excel.encode();
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'DesignThinkingPlan.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/DesignThinkingPlan.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(excel.encode()!, flush: true);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel file saved to $filePath')));
      }
    } catch (e) {
      print('Error generating Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate Excel: $e')));
    }
  }

  void _appendBulletRows(Sheet sheet, String question, List<String> contents,
      List<String> remarks) {
    final maxLength =
        contents.length > remarks.length ? contents.length : remarks.length;

    for (int i = 0; i < maxLength; i++) {
      sheet.appendRow([
        i == 0 ? question : '', // Only show the question in the first row
        i < contents.length
            ? '• ${contents[i]}'
            : '', // Each content in its own cell
        i < remarks.length
            ? '• ${remarks[i]}'
            : '' // Each remark in its own cell
      ]);
    }
  }

  void _showDepartmentDetails(BuildContext context, dynamic school) {
    if (_isDialogOpen) {
      return; // Prevent opening a new dialog if one is already open
    }
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
                          title: const Text(
                            'Department Details',
                            style: TextStyle(
                              fontWeight: FontWeight
                                  .bold, // Set the desired font weight
                              fontSize:
                                  20, // Optional: adjust the font size if needed
                              color: Colors.white, // Change text color to white
                            ),
                          ),
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.green,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _isDialogOpen = false;
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                  const Icon(Icons.search, color: Colors.green),
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
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
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
                                                                        .green),
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

                                                            return Card(
                                                              color: Colors
                                                                      .grey[
                                                                  100], // Dark green background for the card
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          6,
                                                                      horizontal:
                                                                          22),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12), // Rounded corners
                                                              ),
                                                              child: SizedBox(
                                                                height: 80,
                                                                child: Center(
                                                                  child:
                                                                      ListTile(
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
                                                                            json.decode(projectResponse.body);
                                                                        if (projectData
                                                                            is List) {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return Dialog(
                                                                                insetPadding: EdgeInsets.zero,
                                                                                child: SizedBox(
                                                                                  width: MediaQuery.of(context).size.width,
                                                                                  height: MediaQuery.of(context).size.height,
                                                                                  child: Column(
                                                                                    children: [
                                                                                      AppBar(
                                                                                        title: Text(
                                                                                          '${user['users_firstname'] ?? 'N/A'} ${user['users_lastname'] ?? 'N/A'}',
                                                                                          style: const TextStyle(
                                                                                            fontSize: 20,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            color: Colors.white,
                                                                                          ),
                                                                                        ),
                                                                                        backgroundColor: Colors.green,
                                                                                        actions: [
                                                                                          IconButton(
                                                                                            icon: const Icon(Icons.picture_as_pdf_rounded),
                                                                                            onPressed: () {
                                                                                              _printAllLessonsPDF(projectData); // New function to print all lessons
                                                                                            },
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height: 15,
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
                                                                                                height: 78, // Set a fixed height for the card
                                                                                                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Adjusted margin for spacing
                                                                                                padding: const EdgeInsets.all(20), // Increased padding for more space inside the card
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Colors.grey[100],
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
                                                                                                    Row(
                                                                                                      // New Row to combine icon and text
                                                                                                      children: [
                                                                                                        const Icon(
                                                                                                          Icons.folder, // Replace with the appropriate icon for project title
                                                                                                          size: 35, // Adjust size as needed
                                                                                                          color: Colors.green, // Change color if desired
                                                                                                        ),
                                                                                                        const SizedBox(width: 15), // Space between icon and text
                                                                                                        Text(
                                                                                                          project['Lesson'] ?? 'N/A',
                                                                                                          style: const TextStyle(
                                                                                                            fontSize: 16, // Slightly larger font size
                                                                                                            color: Colors.black,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    const Icon(
                                                                                                      Icons.arrow_forward_ios,
                                                                                                      size: 20, // Slightly larger icon size
                                                                                                      color: Colors.grey,
                                                                                                    ),
                                                                                                  ],
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
                                                                        }
                                                                      }
                                                                    },
                                                                    title: Text(
                                                                      '${user['users_lastname'] ?? 'N/A'}, ${user['users_firstname'] ?? 'N/A'}',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                    leading:
                                                                        const CircleAvatar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .green,
                                                                      child:
                                                                          Icon(
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
                                                                          .black,
                                                                    ),
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
                                      );
                                    }
                                  }
                                },
                                child: Card(
                                  color: Colors.grey[
                                      100], // Dark green background for the card
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 22),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Rounded corners
                                  ),
                                  child: SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16),
                                        leading: const Icon(
                                          Icons.group,
                                          color: Colors
                                              .green, // Accent color for icon
                                          size: 50,
                                        ),
                                        title: Text(
                                          department['department_name'] ??
                                              'N/A',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                        subtitle: const Text(
                                          'Tap to view users',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
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
      List<String> projectTitles,
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
            // image: DecorationImage(
            //   image: AssetImage('assets/images/Design_Thinking_Admin.png'),
            //   fit: BoxFit.cover,
            // ),
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
                                Colors.green,
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

                    const SizedBox(height: 250),

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
                ...lessons.expand((lesson) {
                  return [
                    'Mode',
                    'Duration',
                    'Activity',
                    'Lesson',
                    'Output',
                    'Instruction',
                    'CoachDetail',
                    'ActivityRemarks',
                    'OutputRemarks',
                    'InstructionRemarks',
                    'CoachDetailRemarks'
                  ].map((field) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(field)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(lesson[field]?.toString() ?? 'N/A')),
                      ],
                    );
                  });
                }).toList(),
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
