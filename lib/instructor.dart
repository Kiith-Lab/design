import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

void main() {
  runApp(const MaterialApp(home: UserDetailPage()));
}

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key});

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  Map<String, dynamic>? selectedUser;
  String? selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    hint: const Text('Select a user'),
                    value: selectedUser,
                    onChanged: (Map<String, dynamic>? newValue) {
                      setState(() {
                        selectedUser = newValue;
                      });
                    },
                    items: snapshot.data!.map((Map<String, dynamic> user) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: user,
                        child: Text(user['username'] ?? 'N/A'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Select a department'),
                    value: selectedDepartment,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDepartment = newValue;
                      });
                    },
                    items: <String>['IT', 'HR', 'Finance', 'Marketing']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (selectedUser != null) ...[
                    Text('Username: ${selectedUser!['username'] ?? 'N/A'}'),
                    Text('Email: ${selectedUser!['email'] ?? 'N/A'}'),
                    Text('Role: ${selectedUser!['role'] ?? 'N/A'}'),
                    if (selectedDepartment != null)
                      Text('Department: $selectedDepartment'),
                    // Add more details as needed
                  ],
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality for the floating action button here
          print('Floating Action Button pressed');
        },
        child: const Icon(Icons.print),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.post(
      Uri.parse('${baseUrl}view.php'),
      body: {'operation': 'getUser'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}

class UserDetailPages extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetailPages({super.key, required this.user});

  @override
  _UserDetailPagesState createState() => _UserDetailPagesState();
}

class _UserDetailPagesState extends State<UserDetailPages> {
  String? selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['username'] ?? 'User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select a department'),
              value: selectedDepartment,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDepartment = newValue;
                });
              },
              items: <String>['IT', 'HR', 'Finance', 'Marketing']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 20,
            ),

            DropdownButton<String>(
              isExpanded: true,
              value: 'Username',
              hint: const Text('Select a User'),
              onChanged: (String? newValue) {
                // Handle dropdown change
              },
              items: <String>['Username']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                      '${widget.user['username'] ?? 'Select a Instructor'}'),
                );
              }).toList(),
            ),
            // Add more details as needed
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality for the floating action button here
          print('Floating Action Button pressed in UserDetailPages');
        },
        child: const Icon(Icons.print),
      ),
    );
  }
}
