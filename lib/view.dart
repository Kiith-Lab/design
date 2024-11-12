import 'package:design/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shadcn_ui/shadcn_ui.dart';

class ViewUserPage extends StatefulWidget {
  const ViewUserPage({super.key});

  @override
  _ViewUserPageState createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  List<dynamic>? users;
  bool _isLoading = true;
  String _errorMessage = '';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 0;
  final int itemsPerPage = 10;
  String _sortOrder = 'A-Z'; // New variable to track sorting order

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  _fetchUsers() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}view.php'),
        body: {'operation': 'getUserNotActive'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        setState(() {
          if (decodedResponse is List) {
            users = decodedResponse;
          } else if (decodedResponse is Map) {
            users = [decodedResponse];
          } else {
            users = [];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load users: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: $e';
      });
    }
  }

  Future<void> _updateUserStatus(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}update.php'), // Replace with your actual endpoint
        body: {
          'users_id': userId.toString(),
          'operation':
              'updateUser' // Indicates that the update operation should be performed
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse != null && decodedResponse['error'] == null) {
          print('User status updated successfully');
          _fetchUsers(); // Refresh the user list to reflect the changes
        } else {
          print('Failed to update user status: ${decodedResponse['error']}');
        }
      } else {
        print('Failed to update user status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalUsersCount = users?.length ?? 0;
    // Sort users based on the selected order
    final sortedUsers = (users ?? []).toList();
    sortedUsers.sort((a, b) {
      int comparison;
      if (_sortOrder == 'A-Z' || _sortOrder == 'Z-A') {
        comparison = a['users_firstname']
            .toLowerCase()
            .compareTo(b['users_firstname'].toLowerCase());
        return _sortOrder == 'A-Z' ? comparison : -comparison;
      } else {
        comparison = a['role_name']
            .toLowerCase()
            .compareTo(b['role_name'].toLowerCase());
        return _sortOrder == 'Admin' ? comparison : -comparison;
      }
    });

    // Filter users based on search query and selected role
    final filteredUsers = sortedUsers.where((user) {
      final matchesSearchQuery = user['users_firstname']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          user['users_lastname']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          user['role_name'].toLowerCase().contains(searchQuery.toLowerCase());

      final matchesRole = (_sortOrder == 'Admin' &&
              user['role_name'].toLowerCase() == 'admin') ||
          (_sortOrder == 'Instructor' &&
              user['role_name'].toLowerCase() == 'instructor') ||
          (_sortOrder != 'Admin' && _sortOrder != 'Instructor');

      return matchesSearchQuery && matchesRole;
    }).toList();

    final paginatedUsers = filteredUsers
        .skip(currentPage * itemsPerPage)
        .take(itemsPerPage)
        .toList();
    final totalPages = (filteredUsers.length / itemsPerPage).ceil();

    final headings = [
      'Full Name',
      'Role',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deactived Users'),
        centerTitle: true,
        backgroundColor: Colors.grey.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search User',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    currentPage = 0; // Reset to first page on search
                  });
                },
              ),
            ),

            // Sort Options
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Showing $totalUsersCount entries'),
                  const Text('Sort by: '),
                  DropdownButton<String>(
                    value: _sortOrder,
                    items: const [
                      DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                      DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'Instructor', child: Text('Instructor')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Table Data
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : users != null && users!.isNotEmpty
                          ? ShadTable(
                              columnCount: headings.length,
                              rowCount: paginatedUsers.length,
                              header: (context, column) {
                                return ShadTableCell.header(
                                  alignment: column == 1
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Text(
                                    headings[column],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              },
                              columnSpanExtent: (index) {
                                if (index == 0) {
                                  return const FixedTableSpanExtent(150);
                                }
                                if (index == 1) {
                                  return const MaxTableSpanExtent(
                                    FixedTableSpanExtent(120),
                                    RemainingTableSpanExtent(),
                                  );
                                }
                                return null;
                              },
                              builder: (context, index) {
                                final user = paginatedUsers[index.row];
                                return ShadTableCell(
                                  alignment: index.column == 1
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons
                                                    .settings_backup_restore_outlined),
                                                title: const Text('Activate'),
                                                onTap: () {
                                                  final userId =
                                                      user['users_id'];
                                                  if (userId != null) {
                                                    // Show a confirmation dialog before updating the status
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          // ignore: prefer_const_constructors
                                                          title: Row(
                                                            children: const [
                                                              Icon(
                                                                  Icons
                                                                      .info_outline,
                                                                  color: Colors
                                                                      .blue),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                'Confirm Activation',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          content: const Text(
                                                            'Are you sure you want to activate this user?',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close the dialog without action
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                foregroundColor:
                                                                    Colors
                                                                        .red, // Text color
                                                                backgroundColor: Colors
                                                                    .red
                                                                    .withOpacity(
                                                                        0.1), // Button background color
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        12),
                                                              ),
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                _updateUserStatus(
                                                                    int.parse(userId
                                                                        .toString()));
                                                                Navigator.pop(
                                                                    context); // Close the dialog and page if needed
                                                              },
                                                              style: TextButton
                                                                  .styleFrom(
                                                                foregroundColor:
                                                                    Colors
                                                                        .white, // Text color
                                                                backgroundColor:
                                                                    Colors
                                                                        .green, // Button background color
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        12),
                                                              ),
                                                              child: const Text(
                                                                  'Activate'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Error: User ID is missing')),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      index.column == 0
                                          ? '${user['users_firstname'] ?? 'N/A'} ${user['users_lastname'] ?? 'N/A'}'
                                          : user['role_name'] ?? 'N/A',
                                      style: TextStyle(
                                        fontWeight: index.column == 0
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text(
                                'No user data available',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
            ),

            // Pagination Controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: currentPage > 0
                        ? () {
                            setState(() {
                              currentPage--;
                            });
                          }
                        : null,
                  ),
                  Text(
                    'Page ${currentPage + 1} of $totalPages',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: currentPage < totalPages - 1
                        ? () {
                            setState(() {
                              currentPage++;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
