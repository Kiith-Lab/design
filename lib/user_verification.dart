import 'dart:convert';

import 'package:design/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shadcn_ui/shadcn_ui.dart';

class UserVerification extends StatefulWidget {
  const UserVerification({Key? key}) : super(key: key);

  @override
  _UserVerificationState createState() => _UserVerificationState();
}

class _UserVerificationState extends State<UserVerification> {
  List<dynamic>? users;
  bool _isLoading = true;
  String _errorMessage = '';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 0;
  final int itemsPerPage = 10;

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

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users?.where((user) {
          return user['users_firstname']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              user['users_lastname']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              user['role_name']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }).toList() ??
        [];

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
        title: const Text('Users Verification'),
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
                                                leading:
                                                    const Icon(Icons.archive),
                                                title: const Text('Archive'),
                                                onTap: () {
                                                  // Handle archive action
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.edit),
                                                title: const Text('Edit'),
                                                onTap: () {
                                                  // Handle edit action
                                                  Navigator.pop(context);
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
