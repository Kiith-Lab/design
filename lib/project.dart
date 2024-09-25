import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: ProjectPage()));
}

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Row(
              children: [Text("Project")],
          )
        ],
      ),
    );
  }
}