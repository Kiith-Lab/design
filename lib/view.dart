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
          // Check if response is a list or a single object
          if (decodedResponse is List) {
            users = decodedResponse;
          } else if (decodedResponse is Map) {
            users = [decodedResponse]; // Wrap the single user object in a list
          } else {
            users = []; // Handle case where neither list nor map is returned
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  currentPage = 0; // Reset to first page on search
                });
              },
            ),
          ),
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
                              final isLast = column == headings.length - 1;
                              return ShadTableCell.header(
                                alignment:
                                    isLast ? Alignment.centerRight : null,
                                child: Text(headings[column]),
                              );
                            },
                            columnSpanExtent: (index) {
                              if (index == 1)
                                return const FixedTableSpanExtent(150);
                              if (index == 2) {
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
                                alignment: index.column == headings.length - 1
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
                                              leading: Icon(Icons.archive),
                                              title: Text('Archive'),
                                              onTap: () {
                                                // Handle archive action
                                                Navigator.pop(context);
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.edit),
                                              title: Text('Edit'),
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
                                    style: index.column == 0
                                        ? const TextStyle(
                                            fontWeight: FontWeight.w500)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(child: Text('No user data available')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                ),
                Text('Page ${currentPage + 1} of $totalPages'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
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
    );
  }
}
