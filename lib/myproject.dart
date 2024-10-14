import 'dart:ui';

import 'package:design/empaproject.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart';

class MyProjectPage extends StatefulWidget {
  const MyProjectPage({super.key});

  @override
  _MyProjectPageState createState() => _MyProjectPageState();
}

class _MyProjectPageState extends State<MyProjectPage> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _addProject() async {
    const String url = "${baseUrl}add.php";
    final Map<String, dynamic> requestBody = {
      'operation': 'addProject',
      'json': jsonEncode({
        'project_userId': 1, // Replace with actual user ID
        'project_subject_code': _subjectController.text,
        'project_subject_description': _descriptionController.text,
        'project_title': _projectNameController.text,
        'project_description': _descriptionController.text,
        'project_start_date': _startDateController.text,
        'project_end_date': _endDateController.text,
      }),
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final int projectId = int.parse(responseData['id'].toString());
          print('Fetched project ID: $projectId');
          await _fetchAllDataAndNavigate(projectId);
        } else {
          print('Failed to add project: ${responseData['error']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to add project: ${responseData['error']}')),
          );
        }
      } else {
        print('Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> _fetchAllDataAndNavigate(int projectId) async {
    const String url = "${baseUrl}view.php";
    final Map<String, String> requestBody = {
      'operation': 'getProject',
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('error')) {
          print('Failed to retrieve project data: ${responseData['error']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to retrieve project data: ${responseData['error']}')),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmpathyProjectPage(
                projectId: projectId,
              ),
            ),
          );
        }
      } else {
        print('Server error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 14, 14, 14)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0.0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfff4faf3),
              Color(0xfff4faf3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 90),
                    const Center(
                      child: Text(
                        'C R E A T E  L I S T',
                        style: TextStyle(
                          fontSize: 30, // Increased font size to make it bigger
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Changed color to black
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Container to wrap all TextFields
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 0, 148, 32)
                                .withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'PROJECT:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Changed color to black
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _projectNameController,
                            decoration: InputDecoration(
                              labelText: 'Enter Project Name',
                              labelStyle: TextStyle(
                                  color:
                                      Colors.black), // Changed color to black
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'PROJECT DESCRIPTION:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Changed color to black
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Enter Project Description',
                              labelStyle: TextStyle(
                                  color:
                                      Colors.black), // Changed color to black
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'SUBJECT:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Changed color to black
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _subjectController,
                            decoration: InputDecoration(
                              labelText: 'Enter Subject',
                              labelStyle: TextStyle(
                                  color:
                                      Colors.black), // Changed color to black
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'START DATE:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Changed color to black
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _startDateController,
                            decoration: InputDecoration(
                              labelText: 'Enter Start Date',
                              labelStyle: TextStyle(
                                  color:
                                      Colors.black), // Changed color to black
                            ),
                            onTap: () {
                              _selectDate(context, _startDateController);
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'END DATE:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Changed color to black
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _endDateController,
                            decoration: InputDecoration(
                              labelText: 'Enter End Date',
                              labelStyle: TextStyle(
                                  color:
                                      Colors.black), // Changed color to black
                            ),
                            onTap: () {
                              _selectDate(context, _endDateController);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFF76BC6C).withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF76BC6C).withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _addProject();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF76BC6C).withOpacity(0.3),
                          shadowColor: Color(0xFF76BC6C).withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Changed color to black
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
