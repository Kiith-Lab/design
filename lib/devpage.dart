import 'package:design/secondpage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DevPage(
    usersId: '',
  ));
}

class DevPage extends StatelessWidget {
  final String usersId; // Add this line

  const DevPage({super.key, required this.usersId}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DeveloperPage(usersId: usersId), // Pass usersId to DeveloperPage
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          bodyMedium: TextStyle(color: Color.fromARGB(137, 252, 252, 252)),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class DeveloperPage extends StatelessWidget {
  final String usersId;

  const DeveloperPage({super.key, required this.usersId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4A148C),
              Color(0xFF6A1B9A)
            ], // Dark violet gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: AssetImage(
              'assets/images/deve.gif', // Replace with your local GIF path
            ),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Secondpage(
                                  usersId: usersId)), // Pass usersId back
                        );
                      },
                    ),
                  ),
                  const Text(
                    'Dev Team',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'User ID: $usersId', // Display usersId
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: const [
                  DeveloperTile(
                    name: 'Kert Ice Roque Kert',
                    role: 'Backend Developer / UI/UX',
                    imageUrl: 'assets/images/ke.png',
                  ),
                  DeveloperTile(
                    name: 'Joshua Calma',
                    role: 'Backend Developer',
                    imageUrl: 'assets/images/bob.png',
                  ),
                  DeveloperTile(
                    name: 'Christian Keith Abacahin',
                    role: 'Frontend Developer / UI/UX',
                    imageUrl: 'assets/images/eva.png',
                  ),
                  DeveloperTile(
                    name: 'Mirah Mea Aguilar',
                    role: 'Frontend Developer / UI/UX',
                    imageUrl: 'assets/images/carol.png',
                  ),
                  DeveloperTile(
                    name: 'Joemari Obrial',
                    role: 'Frontend Developer / UI/UX',
                    imageUrl: 'assets/images/david.png',
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

class DeveloperTile extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;

  const DeveloperTile({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white
          .withOpacity(0.10), // White card background with some transparency
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      margin: const EdgeInsets.only(bottom: 16.0), // Margin between cards
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Inner padding
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(imageUrl),
              radius: 40.0, // Circular image
            ),
            const SizedBox(height: 16.0), // Space between image and text
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Text(
              role,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 16.0), // Space before social icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.linked_camera),
                  onPressed: () {
                    // Action for LinkedIn
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () {
                    // Action for GitHub
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () {
                    // Action for email
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
