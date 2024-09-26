import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

class EmpathyProjectPage extends StatefulWidget {
  final int projectId;
  const EmpathyProjectPage({super.key, required this.projectId});

  @override
  _EmpathyProjectPageState createState() => _EmpathyProjectPageState();
}

class _EmpathyProjectPageState extends State<EmpathyProjectPage> {
  final TextEditingController activitiesController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController outputsController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController coachDetailsController = TextEditingController();
  String? selectedLesson;
  String? selectedMode;
  List<Map<String, dynamic>> modes = [];
  List<Map<String, dynamic>> lessons = [];
  List<Map<String, dynamic>> selectedLessons = [];
  List<Map<String, dynamic>> allSelectedLessons = [];
  String? masterModuleName;
  int currentStep = 0;
  int? lastInsertedModeId;
  int? lastInsertedDurationId;
  int? lastInsertedCoachHeaderId;

  List<Map<String, dynamic>> allAddedData = [];

  List<int> insertedIds = [];

  int? lastInsertedActivityId;
  int? lastInsertedCardId;
  int? lastInsertedOutputId;
  int? lastInsertedInstructionId;
  int? lastInsertedFolderId;

  List<String> addedActivities = [];
  List<String> addedOutputs = [];
  List<String> addedInstructions = [];
  List<String> addedCoachDetails = [];

  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    fetchModes();
  }

  Future<void> fetchModes() async {
    try {
      String url = "${baseUrl}view.php";
      Map<String, String> requestBody = {
        'operation': 'GetModes',
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String trimmedBody = response.body.trim();
        var decodedData = jsonDecode(trimmedBody);

        if (decodedData is List && decodedData.isNotEmpty) {
          setState(() {
            modes = List<Map<String, dynamic>>.from(decodedData);
          });
        } else {
          setState(() {
            modes = [];
          });
        }
      } else {
        throw Exception('Failed to load modes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching modes: $e');
      setState(() {
        modes = [];
      });
    }
  }

  Future<void> fetchLessons(String modeId) async {
    try {
      String url = "${baseUrl}view.php";
      Map<String, String> requestBody = {
        'operation': 'getLessons',
        'modeId': modeId,
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String trimmedBody = response.body.trim();
        var decodedData = jsonDecode(trimmedBody);

        if (decodedData is List && decodedData.isNotEmpty) {
          setState(() {
            lessons = decodedData.map((lesson) {
              return Map<String, dynamic>.from(lesson);
            }).toList();
            masterModuleName = lessons[0]['module_master_name'] as String?;
          });
        } else if (decodedData is Map<String, dynamic>) {
          setState(() {
            lessons = [decodedData];
            masterModuleName = decodedData['module_master_name'] as String?;
          });
        } else {
          setState(() {
            lessons = [];
            masterModuleName = 'No module name available';
          });
        }
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lessons: $e');
      setState(() {
        lessons = [];
        masterModuleName = 'Error loading module name';
      });
    }
  }

  Future<void> addMode() async {
    if (selectedMode == null) {
      print('No mode selected');
      return;
    }

    // Check if the mode has already been added
    if (allAddedData.any((item) => item['type'] == 'Mode' && item['value'] == modes.firstWhere((mode) => mode['module_master_id'].toString() == selectedMode)['module_master_name'])) {
      print('Mode already added');
      return;
    }

    try {
      String url = "${baseUrl}masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addMode',
        'json': jsonEncode({
          'project_modules_projectId': widget.projectId.toString(),
          'project_modules_masterId': selectedMode,
        }),
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('Mode added successfully');
          setState(() {
            lastInsertedModeId = int.parse(decodedData['id']);
            currentStep++;
            allAddedData.add({
              'type': 'Mode',
              'value': modes.firstWhere((mode) =>
                  mode['module_master_id'].toString() ==
                  selectedMode)['module_master_name']
            });
          });
        } else {
          print('Failed to add mode: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to add mode: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding mode: $e');
    }
  }

  Future<void> addDuration() async {
    if (lastInsertedModeId == null) {
      print('No mode ID available');
      return;
    }

    // Check if the duration has already been added
    if (allAddedData.any((item) => item['type'] == 'Duration' && item['value'] == durationController.text)) {
      print('Duration already added');
      return;
    }

    try {
      String url = "${baseUrl}masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addDuration',
        'json': jsonEncode({
          'activities_header_modulesId': lastInsertedModeId.toString(),
          'activities_header_duration': durationController.text,
        }),
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('Duration added successfully');
          setState(() {
            lastInsertedDurationId = int.parse(decodedData['id']);
            currentStep++;
            allAddedData
                .add({'type': 'Duration', 'value': durationController.text});
          });
        } else {
          print('Failed to add duration: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to add duration: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding duration: $e');
    }
  }

  Future<void> addActivity() async {
    if (lastInsertedDurationId == null) {
      print('No duration ID available');
      return;
    }

    // Check if the activities have already been added
    if (allAddedData.any((item) => item['type'] == 'Activity' && item['value'] == addedActivities.join(', '))) {
      print('Activities already added');
      return;
    }

    try {
      String url = "${baseUrl}masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addActivity',
        'json': jsonEncode({
          'activities_details_remarks': 'Activity',
          'activities_details_content': jsonEncode(addedActivities),
          'activities_details_headerId': lastInsertedDurationId.toString(),
        }),
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('Activity added successfully');
          setState(() {
            currentStep++;
            allAddedData
                .add({'type': 'Activity', 'value': addedActivities.join(', ')});
            lastInsertedActivityId = int.parse(decodedData['id']);
          });

          // Store the activity details
          var activityDetails = decodedData['activity'];
          print('Activity ID: ${activityDetails['activities_details_id']}');
          // You can store other activity details as needed
        } else {
          print('Failed to add activity: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to add activity: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding activity: $e');
    }
  }

  Future<void> addCard(String cardId) async {
    if (lastInsertedModeId == null) {
      print('No mode ID available');
      return;
    }

    // Check if the card has already been added
    if (allAddedData.any((item) => item['type'] == 'Card' && item['value'] == cardId)) {
      print('Card already added');
      return;
    }

    String url = "${baseUrl}masterlist.php";
    Map<String, String> requestBody = {
      'operation': 'addCards',
      'json': jsonEncode({
        'project_cards_cardId': cardId,
        'project_cards_modulesId': lastInsertedModeId.toString(),
        'project_cards_remarks': ''
      }),
    };

    try {
      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to add card to database: ${response.statusCode}');
      }

      String trimmedBody = response.body.trim();
      if (trimmedBody.isEmpty) {
        throw Exception('Empty response received');
      }

      var decodedData = jsonDecode(trimmedBody);
      if (decodedData['success'] != true) {
        throw Exception(
            'Failed to add card to database: ${decodedData['error']}');
      }

      print('Card added successfully');
      setState(() {
        lastInsertedCardId = int.parse(decodedData['id']);
        allAddedData.add({'type': 'Card', 'value': cardId});
      });
    } catch (e) {
      print('Error adding card: $e');
      throw Exception('Failed to add card to database: $e');
    }
  }

  Future<void> addOutput() async {
    if (lastInsertedModeId == null) {
      print('No mode ID available');
      return;
    }

    // Check if the outputs have already been added
    if (allAddedData.any((item) => item['type'] == 'Output' && item['value'] == addedOutputs.join(', '))) {
      print('Outputs already added');
      return;
    }

    try {
      String url = "${baseUrl}masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addOutput',
        'json': jsonEncode({
          'outputs_moduleId': lastInsertedModeId.toString(),
          'outputs_remarks': 'Output',
          'outputs_content': jsonEncode(addedOutputs),
        }),
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('Output added successfully');
          setState(() {
            currentStep++;
            allAddedData
                .add({'type': 'Output', 'value': addedOutputs.join(', ')});
            lastInsertedOutputId = int.parse(decodedData['id']);
          });
        } else {
          print('Failed to add output: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to add output: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding output: $e');
    }
  }

  Future<void> addInstruction() async {
    if (lastInsertedModeId == null) {
      print('No mode ID available');
      return;
    }

    // Check if the instructions have already been added
    if (allAddedData.any((item) => item['type'] == 'Instruction' && item['value'] == addedInstructions.join(', '))) {
      print('Instructions already added');
      return;
    }

    try {
      String url = "${baseUrl}masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addInstruction',
        'json': jsonEncode({
          'instruction_remarks': 'Instruction',
          'instruction_modulesId': lastInsertedModeId.toString(),
          'instruction_content': jsonEncode(addedInstructions),
        }),
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('Instruction added successfully');
          setState(() {
            currentStep++; // Skip to coach header step
            allAddedData.add(
                {'type': 'Instruction', 'value': addedInstructions.join(', ')});
            lastInsertedInstructionId = int.parse(decodedData['id']);
          });
        } else {
          print('Failed to add instruction: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to add instruction: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding instruction: $e');
    }
  }

  Future<void> addCoachDetails() async {
    // Check if the coach details have already been added
    if (allAddedData.any((item) => item['type'] == 'Coach Details' && item['value'] == addedCoachDetails.join(', '))) {
      print('Coach Details already added');
      return;
    }

    try {
      String url = "${baseUrl}masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addCoachDetails',
        'json': jsonEncode({
          'coach_detail_coachheaderId': '1',
          'coach_detail_content': jsonEncode(addedCoachDetails),
          'coach_detail_renarks': 'Coach Details',
        }),
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('Coach Details added successfully');
          int coachDetailsId = int.parse(decodedData['id']);

          // Store all inserted IDs
          insertedIds = [
            lastInsertedModeId!,
            lastInsertedDurationId!,
            lastInsertedActivityId!,
            lastInsertedCardId!,
            lastInsertedOutputId!,
            lastInsertedInstructionId!,
            coachDetailsId,
          ];

          // Store IDs in local storage
          await storeInsertedIds();

          // Add to folder operation
          await addToFolder();

          setState(() {
            currentStep = 0; // Reset to the first step
            allAddedData.add({
              'type': 'Coach Details',
              'value': addedCoachDetails.join(', ')
            });
          });
        } else {
          print('Failed to add coach details: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to add coach details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding coach details: $e');
    }
  }

  Future<void> storeInsertedIds() async {
    try {
      // Debugging print to check insertedIds
      print('Attempting to store IDs: ${insertedIds.join(', ')}');

      // Get SharedPreferences instance
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Store the IDs
      await prefs.setStringList(
          'insertedIds', insertedIds.map((id) => id.toString()).toList());

      print('Stored IDs successfully: ${insertedIds.join(', ')}');
    } catch (e) {
      print('Error storing inserted IDs: $e');
      if (e is MissingPluginException) {
        print('Ensure SharedPreferences is properly initialized');
      }
    }
  }

  Future<void> addToFolder() async {
    try {
      // Ensure insertedIds is populated before using it
      if (insertedIds.length < 7) {
        print(
            'Error: Not all required IDs are available. Current IDs: ${insertedIds.join(', ')}');
        return;
      }

      String url = "${baseUrl}masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addFolder',
        'json': jsonEncode({
          'projectId': widget.projectId.toString(),
          'project_moduleId': insertedIds[0].toString(),
          'activities_detailId': lastInsertedActivityId.toString(),
          'project_cardsId': insertedIds[3].toString(),
          'outputId': insertedIds[4].toString(),
          'instructionId': insertedIds[5].toString(),
          'coach_detailsId': insertedIds[6].toString(),
        }),
      };

      print('Adding to folder with IDs:');
      print('projectId: ${widget.projectId}');
      print('project_moduleId: ${insertedIds[0]}');
      print('activities_detailId: $lastInsertedActivityId');
      print('project_cardsId: ${insertedIds[3]}');
      print('outputId: ${insertedIds[4]}');
      print('instructionId: ${insertedIds[5]}');
      print('coach_detailsId: ${insertedIds[6]}');

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String trimmedBody = response.body.trim();
        if (trimmedBody.isEmpty) {
          // Save the IDs to local storage if the response is empty
          await storeInsertedIds();
          throw Exception('Empty response received');
        }

        var decodedData = jsonDecode(trimmedBody);
        if (decodedData['success'] == true) {
          print('Added to folder successfully');
          lastInsertedFolderId = int.parse(decodedData['id']);
          
          // Save the folder ID along with other IDs
          insertedIds.add(lastInsertedFolderId!);
          await storeInsertedIds();
        } else {
          print('Failed to add to folder: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to add to folder: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding to folder: $e');
    }
  }

  Future<void> updateData() async {
    if (lastInsertedModeId == null) {
      print('No mode ID available for update');
      return;
    }

    try {
      String url = "${baseUrl}masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'updateData',
        'json': jsonEncode({
          'modeId': lastInsertedModeId.toString(),
          'duration': durationController.text,
          'activities': jsonEncode(addedActivities),
          'cards': jsonEncode(selectedLessons.map((lesson) => lesson['cards_id']).toList()),
          'outputs': jsonEncode(addedOutputs),
          'instructions': jsonEncode(addedInstructions),
          'coachDetails': jsonEncode(addedCoachDetails),
        }),
      };

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('Data updated successfully');
          // Update the local state or perform any necessary actions after successful update
        } else {
          print('Failed to update data: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empathy Project'),
        backgroundColor: Colors.green.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModeDropdown(),
            const SizedBox(height: 20),
            _buildTextField(durationController, 'Duration'),
            const SizedBox(height: 20),
            _buildTextField(activitiesController, 'Activities'),
            const SizedBox(height: 10),
            _buildAddButton('Add Activity', () {
              setState(() {
                addedActivities.add(activitiesController.text);
                activitiesController.clear();
              });
            }),
            _buildList(addedActivities),
            const SizedBox(height: 20),
            _buildLessonDropdown(),
            const SizedBox(height: 10),
            _buildAddButton('Add Lesson', _addLesson),
            _buildList(selectedLessons.map((lesson) => lesson['cards_title'] as String).toList()),
            const SizedBox(height: 20),
            _buildTextField(outputsController, 'Outputs'),
            const SizedBox(height: 10),
            _buildAddButton('Add Output', () {
              setState(() {
                addedOutputs.add(outputsController.text);
                outputsController.clear();
              });
            }),
            _buildList(addedOutputs),
            const SizedBox(height: 20),
            _buildTextField(instructionsController, 'Instructions'),
            const SizedBox(height: 10),
            _buildAddButton('Add Instruction', () {
              setState(() {
                addedInstructions.add(instructionsController.text);
                instructionsController.clear();
              });
            }),
            _buildList(addedInstructions),
            const SizedBox(height: 20),
            _buildTextField(coachDetailsController, 'Coach Details'),
            const SizedBox(height: 10),
            _buildAddButton('Add Coach Detail', () {
              setState(() {
                addedCoachDetails.add(coachDetailsController.text);
                coachDetailsController.clear();
              });
            }),
            _buildList(addedCoachDetails),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('Submit All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select Mode',
        border: OutlineInputBorder(),
      ),
      value: selectedMode,
      items: modes.map((mode) {
        return DropdownMenuItem<String>(
          value: mode['module_master_id'].toString(),
          child: Text(mode['module_master_name']),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          if (selectedMode != newValue) {
            selectedMode = newValue;
            selectedLesson = null;
            isUpdating = false;
            if (newValue != null) {
              fetchLessons(newValue);
              
              // Clear all controllers and lists when a new mode is selected
              durationController.clear();
              activitiesController.clear();
              outputsController.clear();
              instructionsController.clear();
              coachDetailsController.clear();
              addedActivities.clear();
              addedOutputs.clear();
              addedInstructions.clear();
              addedCoachDetails.clear();
              selectedLessons.clear();
            }
          } else {
            isUpdating = true;
          }
        });
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildAddButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
      ),
      child: Text(label),
    );
  }

  Widget _buildList(List<String> items) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
        );
      },
    );
  }

  Widget _buildLessonDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Select a lesson',
        border: OutlineInputBorder(),
      ),
      value: selectedLesson,
      items: lessons.map((lesson) {
        return DropdownMenuItem<String>(
          value: lesson['back_cards_header_id'].toString(),
          child: Text('${lesson['cards_title']}'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedLesson = newValue;
        });
      },
    );
  }

  void _addLesson() {
    if (selectedLesson != null) {
      setState(() {
        Map<String, dynamic> addedLesson = lessons.firstWhere(
          (lesson) => lesson['back_cards_header_id'].toString() == selectedLesson,
          orElse: () => {'cards_title': 'Unknown', 'cards_id': selectedLesson},
        );
        selectedLessons.add(addedLesson);
        selectedLesson = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a lesson')),
      );
    }
  }

  void _submitAll() async {
    if (isUpdating) {
      await updateData();
    } else {
      await addMode();
      await addDuration();
      await addActivity();
      for (var lesson in selectedLessons) {
        await addCard(lesson['cards_id'].toString());
      }
      await addOutput();
      await addInstruction();
      await addCoachDetails();
      await addToFolder();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isUpdating ? 'Data updated successfully' : 'All data submitted successfully')),
    );
  }
}
