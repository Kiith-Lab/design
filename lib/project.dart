import 'package:design/config.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // HTTP package for requests

void main() {
  runApp(const MaterialApp(home: ProjectPage()));
}

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  List projects = [];
  List filteredProjects = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProjects(); // Fetch the data when the page initializes
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
        filterProjects();
      });
    });
  }

  // Function to fetch project data from PHP server
  Future<void> fetchProjects() async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}view.php'),
        body: {'operation': 'getAllProjects'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          projects = data;
          filteredProjects = data; // Initialize filtered list with all projects
        });
      } else {
        throw Exception('Failed to load projects');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  // Function to filter the projects based on the search query
  void filterProjects() {
    setState(() {
      filteredProjects = projects
          .where((project) =>
              project['project_title']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              project['project_subject_code']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  // Function to display project details in a modal dialog
  void showProjectDetails(BuildContext context, Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(project['project_title']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Subject Code: ${project['project_subject_code']}'),
                const SizedBox(height: 10),
                Text(
                    'Subject Description: ${project['project_subject_description']}'),
                const SizedBox(height: 10),
                Text('Project Description: ${project['project_description']}'),
                const SizedBox(height: 10),
                Text('Start Date: ${project['project_start_date']}'),
                const SizedBox(height: 10),
                Text('End Date: ${project['project_end_date']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Project Title or Subject Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredProjects.isEmpty
                ? const Center(
                    child: CircularProgressIndicator()) // Loading indicator
                : ListView.builder(
                    itemCount: filteredProjects.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Text(filteredProjects[index]['project_title']),
                          subtitle: Text(
                              'Subject Code: ${filteredProjects[index]['project_subject_code']}'),
                          onTap: () {
                            showProjectDetails(
                                context, filteredProjects[index]);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
