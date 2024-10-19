import 'dart:convert';

import 'package:design/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserVerification extends StatefulWidget {
  const UserVerification({super.key});

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

  Future<void> _fetchUsers() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}view.php'),
        body: {'operation': 'getUserNotVerify'},
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          users = (decodedResponse is List) ? decodedResponse : [];
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

  Future<void> _saveUpdate(int userId) async {
    setState(() {
      _isLoading = true; // Start loading before the request
      _errorMessage = ''; // Reset error message
    });

    try {
      final jsonData = jsonEncode({'users_id': userId});
      final response = await http.post(
        Uri.parse('${baseUrl}view.php'),
        body: {"json": jsonData, "operation": "UserVerify"},
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        setState(() {
          _isLoading = false;
          if (decodedResponse['success'] != null &&
              decodedResponse['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User verified successfully!')),
            );
            _fetchUsers(); // Refresh the user list
          } else {
            _errorMessage =
                decodedResponse['message'] ?? 'Unknown error occurred';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $_errorMessage')),
            );
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to verify user: ${response.statusCode}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $_errorMessage')),
          );
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to verify user: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
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

            // List Data
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(child: Text(_errorMessage))
                      : users != null && users!.isNotEmpty
                          ? ListView.builder(
                              itemCount: paginatedUsers.length,
                              itemBuilder: (context, index) {
                                final user = paginatedUsers[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0), // Optional margin
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300], // Background color
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Rounded corners
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '${user['users_firstname'] ?? 'N/A'} ${user['users_lastname'] ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(user['role_name'] ?? 'N/A'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            final userId = user['users_id'];
                                            _saveUpdate(userId);
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors
                                                .green[700], // Green background
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8.0), // Rounded corners
                                            ),
                                            minimumSize: const Size(
                                                0, 40), // Set minimum height
                                          ),
                                          child: const Text(
                                            'Accept',
                                            style: TextStyle(
                                              color: Colors.white, // White text
                                            ),
                                          ),
                                        ),
                                        // Additional button for deny action can be added here
                                      ],
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
