import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Import main.dart for navigation

class OTPPage extends StatelessWidget {
  final String email;

  OTPPage({required this.email});

  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _verifyOTPAndUpdatePassword(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedOtp = prefs.getString('otp');
    String inputOtp = _otpController.text;
    String newPassword = _passwordController.text;

    if (storedOtp != null && storedOtp == inputOtp) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // Simulate a delay
      await Future.delayed(Duration(seconds: 2));

      // Make a POST request to update the password
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/email.php'),
        body: {
          'operation': 'verifyOTPAndUpdatePassword',
          'json': json.encode({
            'email': email,
            'otp': inputOtp,
            'newPassword': newPassword,
          }),
        },
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData'); // Log the response data
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to main.dart
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginAppes()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${responseData['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('Server Error: ${response.statusCode}'); // Log server error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server error. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'Enter OTP'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => _verifyOTPAndUpdatePassword(context),
              child: Text('Verify OTP and Update Password'),
            ),
          ],
        ),
      ),
    );
  }
}
