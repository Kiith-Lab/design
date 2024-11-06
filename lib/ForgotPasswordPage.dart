import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'OTPPage.dart'; // Ensure this import is correct
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text;

      // Make a POST request to the PHP API
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/email.php'),
        body: {
          'operation': 'getEmail',
          'json': json.encode({'email': email}),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List && responseData.isNotEmpty) {
          print('Email exists in the database.');

          // Email exists in the database, generate OTP
          final otpResponse = await http.post(
            Uri.parse('http://localhost/design/lib/api/email.php'),
            body: {
              'operation': 'generateOTP',
              'json': json.encode({'email': email}),
            },
          );

          // print('OTP Response status: ${otpResponse.statusCode}');
          // print('OTP Response body: ${otpResponse.body}');

          if (otpResponse.statusCode == 200) {
            final otpData = json.decode(otpResponse.body);
            if (otpData['success'] == true) {
              print('OTP generated successfully.');

              // Convert OTP to String
              String otpString = otpData['otp'].toString();

              // Save OTP locally
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('otp', otpString);

              // Send OTP email via API
              final emailResponse = await http.post(
                Uri.parse('http://localhost/design/lib/api/email.php'),
                body: {
                  'operation': 'sendEmail',
                  'json': json.encode({'email': email, 'otp': otpString}),
                },
              );

              // print('Email Response status: ${emailResponse.statusCode}');
              // print('Email Response body: ${emailResponse.body}');

              if (emailResponse.statusCode == 200) {
                final emailData = json.decode(emailResponse.body);
                if (emailData['success'] == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OTPPage(email: email),
                    ),
                  );
                } else {
                  print('Failed to send email.');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Failed to send email: ${emailData['error']}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                print('Failed to send email. Server error.');
              }
            } else {
              print('Failed to generate OTP.');
            }
          } else {
            print('Failed to generate OTP. Server error.');
          }
        } else {
          print('Email does not exist in the database.');
          // Email does not exist in the database
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email does not exist in our records.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Server error when checking email.');
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server error. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter your email address to receive a password reset link.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Add more email validation if necessary
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      print("Button pressed"); // Debugging line
                      _sendResetLink();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Send Reset OTP',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
