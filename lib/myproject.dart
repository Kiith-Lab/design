import 'dart:ui';

import 'package:design/empaproject.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

class MyProjectPage extends StatefulWidget {
  final String usersId; // Add this line

  const MyProjectPage({super.key, required this.usersId}); // Modify constructor

  @override
  _MyProjectPageState createState() => _MyProjectPageState();
}

class _MyProjectPageState extends State<MyProjectPage> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();

    // Add listeners to save data when text changes
    _projectNameController.addListener(_saveFormData);
    _subjectController.addListener(_saveFormData);
    _descriptionController.addListener(_saveFormData);
    _startDateController.addListener(_saveFormData);
    _endDateController.addListener(_saveFormData);
  }

  @override
  void dispose() {
    // Remove listeners when disposing
    _projectNameController.removeListener(_saveFormData);
    _subjectController.removeListener(_saveFormData);
    _descriptionController.removeListener(_saveFormData);
    _startDateController.removeListener(_saveFormData);
    _endDateController.removeListener(_saveFormData);

    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _projectNameController.text = prefs.getString('project_name') ?? '';
      _subjectController.text = prefs.getString('subject') ?? '';
      _descriptionController.text = prefs.getString('description') ?? '';
      _startDateController.text = prefs.getString('start_date') ?? '';
      _endDateController.text = prefs.getString('end_date') ?? '';
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('project_name', _projectNameController.text);
    await prefs.setString('subject', _subjectController.text);
    await prefs.setString('description', _descriptionController.text);
    await prefs.setString('start_date', _startDateController.text);
    await prefs.setString('end_date', _endDateController.text);
  }

  // Add this method to clear saved data after successful project creation
  Future<void> _clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('project_name');
    await prefs.remove('subject');
    await prefs.remove('description');
    await prefs.remove('start_date');
    await prefs.remove('end_date');
  }

  Future<void> _addProject() async {
    // Validate that all required fields are filled
    if (_projectNameController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return; // Exit the function if validation fails
    }

    // Instead of sending data to the database, prepare it for navigation
    final Map<String, dynamic> projectData = {
      'project_userId': widget.usersId, // Use widget.usersId here
      'project_subject_code': _subjectController.text,
      'project_subject_description': _descriptionController.text,
      'project_title': _projectNameController.text,
      'project_description': _descriptionController.text,
      'project_start_date': _startDateController.text,
      'project_end_date': _endDateController.text,
    };

    // Clear saved data after successful creation
    await _clearSavedData();

    // Navigate with the project data
    await _fetchAllDataAndNavigate(projectData);
  }

  Future<void> _fetchAllDataAndNavigate(
      Map<String, dynamic> projectData) async {
    // Directly navigate to the EmpathyProjectPage without making an HTTP request
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmpathyProjectPage(
          projectData: projectData, // Pass the entire project data map
        ),
      ),
    );
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
          onPressed: () async {
            // Show confirmation dialog
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text(
                    'You have unsaved changes. Do you want to discard them?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Clear input fields
                      _projectNameController.clear();
                      _subjectController.clear();
                      _descriptionController.clear();
                      _startDateController.clear();
                      _endDateController.clear();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Discard'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _saveFormData(); // Save form data when "Keep" is pressed
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Keep'),
                  ),
                ],
              ),
            );

            if (shouldPop ?? false) {
              Navigator.of(context).pop();
            }
          },
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0.0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                            decoration: const InputDecoration(
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
                            decoration: const InputDecoration(
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
                            decoration: const InputDecoration(
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
                            decoration: const InputDecoration(
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
                            decoration: const InputDecoration(
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
                        color: const Color(0xFF76BC6C).withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF76BC6C).withOpacity(0.1),
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
                          backgroundColor:
                              const Color(0xFF76BC6C).withOpacity(0.3),
                          shadowColor: const Color(0xFF76BC6C).withOpacity(0.1),
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
