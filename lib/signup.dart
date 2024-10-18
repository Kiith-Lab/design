import 'package:design/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _selectedSchool;
  String? _selectedDepartment;
  String? _selectedRole;

  // List to store school data
  List<Map<String, dynamic>> _schools = [];
  List<Map<String, dynamic>> _departments = [];
  // List<Map<String, dynamic>> _roles = [
  //   {'role_id': '1', 'role_name': 'Student'},
  //   {'role_id': '2', 'role_name': 'Teacher'},
  //   {'role_id': '3', 'role_name': 'Admin'},
  // ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchSchools();
    _fetchDepartments();
  }

  Future<void> _fetchSchools() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}get_schools.php'));
      if (response.statusCode == 200) {
        final List<dynamic> schoolsJson = json.decode(response.body);
        setState(() {
          _schools = schoolsJson
              .map((school) => {
                    'school_id': school['school_id'].toString(),
                    'school_name': school['school_name'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load schools');
      }
    } catch (e) {
      print('Error fetching schools: $e');
    }
  }

  Future<void> _fetchDepartments() async {
    try {
      final response =
          await http.get(Uri.parse('${baseUrl}get_departments.php'));
      if (response.statusCode == 200) {
        final List<dynamic> departmentsJson = json.decode(response.body);
        setState(() {
          _departments = departmentsJson
              .map((department) => {
                    'department_id': department['department_id'].toString(),
                    'department_name': department['department_name'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (e) {
      print('Error fetching departments: $e');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('${baseUrl}signup.php'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'users_school_id': _schoolIdController.text,
            'users_password': _passwordController.text,
            'users_firstname': _firstNameController.text,
            'users_middlename': _middleNameController.text,
            'users_lastname': _lastNameController.text,
            'users_suffix': _suffixController.text,
            'users_schoolId': _selectedSchool ?? '',
            'users_departmantId': _selectedDepartment ?? '',
            'user_email': _emailController.text,
          }),
        );

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
            _clearForm();
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
          }
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during signup: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Network error. Please check your connection and try again.')),
        );
      }
    }
  }

  void _clearForm() {
    _schoolIdController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
    _suffixController.clear();
    _emailController.clear();
    setState(() {
      _selectedSchool = null;
      _selectedDepartment = null;
      _selectedRole = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/mainbg1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.black),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginAppes()),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 150),
                      const Text(
                        'FILL UP THE FORM TO SIGN UP',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 600, // Adjust height as needed
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: [
                            // First Page
                            Column(
                              children: [
                                TextFormField(
                                  controller: _schoolIdController,
                                  decoration: InputDecoration(
                                    labelText: 'School ID',
                                    prefixIcon: const Icon(Icons.school),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter a School ID'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter your First Name'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _middleNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Middle Name',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter your Last Name'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _suffixController,
                                  decoration: InputDecoration(
                                    labelText: 'Suffix',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  // No validator needed, suffix is optional
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Validate the form before moving to the next page
                                    if (_formKey.currentState!.validate()) {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeIn,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(20),
                                  ),
                                  child: const Icon(Icons.arrow_forward),
                                ),
                              ],
                            ),
                            // Second Page
                            Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedSchool,
                                  decoration: InputDecoration(
                                    labelText: 'School',
                                    prefixIcon: const Icon(Icons.school),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  items: _schools
                                      .map((Map<String, dynamic> school) {
                                    return DropdownMenuItem<String>(
                                      value: school['school_id'],
                                      child: Text(school['school_name']),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedSchool = newValue;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select a school'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedDepartment,
                                  decoration: InputDecoration(
                                    labelText: 'Department',
                                    prefixIcon: const Icon(Icons.business),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  items: _departments
                                      .map((Map<String, dynamic> department) {
                                    return DropdownMenuItem<String>(
                                      value: department['department_id'],
                                      child:
                                          Text(department['department_name']),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedDepartment = newValue;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select a department'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                        .hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    suffixIcon: IconButton(
                                      icon: Icon(_isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: _togglePasswordVisibility,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters long';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    suffixIcon: IconButton(
                                      icon: Icon(_isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed:
                                          _toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(20),
                                      ),
                                      child: const Icon(Icons.arrow_back),
                                    ),
                                    ElevatedButton(
                                      onPressed: _signup,
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(20),
                                        backgroundColor: const Color.fromARGB(
                                            255, 241, 255, 210),
                                      ),
                                      child: const Icon(Icons.check),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
