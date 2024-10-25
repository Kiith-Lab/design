import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'color.dart';

class UpdateProjectPage extends StatefulWidget {
  final Map<String, dynamic> initialData; // Add this to receive initial data

  const UpdateProjectPage({super.key, required this.initialData});

  @override
  _UpdateProjectPageState createState() => _UpdateProjectPageState();
}

class _UpdateProjectPageState extends State<UpdateProjectPage> {
  final TextEditingController activitiesController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController outputsController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController coachDetailsController = TextEditingController();

  // New controllers for remarks
  final TextEditingController remarksDurationController =
      TextEditingController();
  final TextEditingController remarksActivityController =
      TextEditingController();
  final TextEditingController remarksLessonController = TextEditingController();
  final TextEditingController remarksOutputController = TextEditingController();
  final TextEditingController remarksInstructionController =
      TextEditingController();
  final TextEditingController remarksCoachDetailsController =
      TextEditingController();

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
  List<int> lastInsertedCardIds = [];
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
    _loadFormState();

    // Initialize controllers with initial data
    activitiesController.text = widget.initialData['activities'] ?? '';
    durationController.text = widget.initialData['duration'] ?? '';
    outputsController.text = widget.initialData['outputs'] ?? '';
    instructionsController.text = widget.initialData['instructions'] ?? '';
    coachDetailsController.text = widget.initialData['coachDetails'] ?? '';

    // Initialize remarks controllers with initial data
    remarksDurationController.text =
        widget.initialData['remarksDuration'] ?? '';
    remarksActivityController.text =
        widget.initialData['remarksActivity'] ?? '';
    remarksLessonController.text = widget.initialData['remarksLesson'] ?? '';
    remarksOutputController.text = widget.initialData['remarksOutput'] ?? '';
    remarksInstructionController.text =
        widget.initialData['remarksInstruction'] ?? '';
    remarksCoachDetailsController.text =
        widget.initialData['remarksCoachDetails'] ?? '';

    // Initialize other fields if needed
    selectedMode = widget.initialData['selectedMode'];
    selectedLessons = List<Map<String, dynamic>>.from(
        widget.initialData['selectedLessons'] ?? []);
    addedActivities =
        List<String>.from(widget.initialData['addedActivities'] ?? []);
    addedOutputs = List<String>.from(widget.initialData['addedOutputs'] ?? []);
    addedInstructions =
        List<String>.from(widget.initialData['addedInstructions'] ?? []);
    addedCoachDetails =
        List<String>.from(widget.initialData['addedCoachDetails'] ?? []);
  }

  Future<void> fetchModes() async {
    try {
      String url = "http://localhost/design/lib/api/view.php";
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
      String url = "http://localhost/design/lib/api/view.php";
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
    if (allAddedData.any((item) =>
        item['type'] == 'Mode' &&
        item['value'] ==
            modes.firstWhere((mode) =>
                mode['module_master_id'].toString() ==
                selectedMode)['module_master_name'])) {
      print('Mode already added');
      return;
    }

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addMode',
        'json': jsonEncode({
          'project_modules_projectId':
              widget.initialData['projectId'].toString(),
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
    if (allAddedData.any((item) =>
        item['type'] == 'Duration' &&
        item['value'] == durationController.text)) {
      print('Duration already added');
      return;
    }

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
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
    if (allAddedData.any((item) =>
        item['type'] == 'Activity' &&
        item['value'] == addedActivities.join(', '))) {
      print('Activities already added');
      print(allAddedData);
      return;
    }

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addActivity',
        'json': jsonEncode({
          'activities_details_remarks':
              remarksActivityController.text, // Use remarks controller
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
    if (allAddedData
        .any((item) => item['type'] == 'Card' && item['value'] == cardId)) {
      print('Card already added');
      return;
    }

    String url = "http://localhost/design/lib/api/masterlist.php";
    Map<String, String> requestBody = {
      'operation': 'addCards',
      'json': jsonEncode({
        'project_cards_cardId': cardId,
        'project_cards_modulesId': lastInsertedModeId.toString(),
        'project_cards_remarks':
            remarksLessonController.text // Use the text property
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
        lastInsertedCardIds.add(int.parse(decodedData['id'])); // Add to list
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
    if (allAddedData.any((item) =>
        item['type'] == 'Output' && item['value'] == addedOutputs.join(', '))) {
      print('Outputs already added');
      return;
    }

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addOutput',
        'json': jsonEncode({
          'outputs_moduleId': lastInsertedModeId.toString(),
          'outputs_remarks':
              remarksOutputController.text, // Use remarks controller
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
    if (allAddedData.any((item) =>
        item['type'] == 'Instruction' &&
        item['value'] == addedInstructions.join(', '))) {
      print('Instructions already added');
      return;
    }

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addInstruction',
        'json': jsonEncode({
          'instruction_remarks':
              remarksInstructionController.text, // Use remarks controller
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
    if (allAddedData.any((item) =>
        item['type'] == 'Coach Details' &&
        item['value'] == addedCoachDetails.join(', '))) {
      print('Coach Details already added');
      return;
    }

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addCoachDetails',
        'json': jsonEncode({
          'coach_detail_coachheaderId': '1',
          'coach_detail_content': jsonEncode(addedCoachDetails),
          'coach_detail_renarks':
              remarksCoachDetailsController.text, // Use remarks controller
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
            ...lastInsertedCardIds,
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

      String url = "http://localhost/design/lib/api/masterlist.php";

      for (int cardId in lastInsertedCardIds) {
        Map<String, String> requestBody = {
          'operation': 'addFolder',
          'json': jsonEncode({
            'projectId': widget.initialData['projectId'].toString(),
            'project_moduleId': insertedIds[0].toString(),
            'activities_detailId': lastInsertedActivityId.toString(),
            'project_cardsId': cardId.toString(),
            'outputId': insertedIds[insertedIds.length - 3].toString(),
            'instructionId': insertedIds[insertedIds.length - 2].toString(),
            'coach_detailsId': insertedIds.last.toString(),
          }),
        };

        print('Adding to folder with IDs:');
        print('projectId: ${widget.initialData['projectId'].toString()}');
        print('project_moduleId: ${insertedIds[0]}');
        print('activities_detailId: $lastInsertedActivityId');
        print('project_cardsId: $cardId');
        print('outputId: ${insertedIds[insertedIds.length - 3]}');
        print('instructionId: ${insertedIds[insertedIds.length - 2]}');
        print('coach_detailsId: ${insertedIds.last}');

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
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'updateData',
        'json': jsonEncode({
          'modeId': lastInsertedModeId.toString(),
          'duration': durationController.text,
          'activities': jsonEncode(addedActivities),
          'cards': jsonEncode(
              selectedLessons.map((lesson) => lesson['cards_id']).toList()),
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
    return WillPopScope(
      onWillPop: () async {
        bool? shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Discard Changes?'),
              content:
                  const Text('Are you sure you want to discard your changes?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Discard'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );
        if (shouldDiscard ?? false) {
          await _saveFormState(); // Save form state before navigating back
        }
        return shouldDiscard ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE6F5E3), // Set the background color
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.08), // Responsive height
              Text(
                'Step ${currentStep + 1} of 7',
                style: const TextStyle(
                  fontSize: 24, // Increased font size
                  fontWeight: FontWeight.bold, // Made the text bolder
                ),
              ), // Displaying the step number
              SizedBox(
                width:
                    MediaQuery.of(context).size.width * 0.8, // Responsive width
                height: MediaQuery.of(context).size.height *
                    0.05, // Responsive height
                child: LinearProgressIndicator(
                  value: currentStep / 7, // Assuming there are 7 steps
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.05), // Added space between the Progress bar and the Input Fields
              _buildPage(currentStep), // Use a method to build the current page
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int step) {
    switch (step) {
      case 0:
        return _buildModeDropdownPage();
      case 1:
        return _buildDurationPage();
      case 2:
        return _buildActivitiesPage();
      case 3:
        return _buildLessonsPage();
      case 4:
        return _buildOutputsPage();
      case 5:
        return _buildInstructionsPage();
      case 6:
        return _buildCoachDetailsPage();
      default:
        return Container(); // Fallback
    }
  }

  Widget _buildModeDropdownPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 23, 128, 23).withOpacity(0.5),
                  spreadRadius: -2.0,
                  blurRadius: 4.0,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height *
                            0.1), // Adjusted responsive margin to reduce space
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Changed to center
                      children: [
                        const Text(
                          'M O D E',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 35), // Increased font size
                        ),
                        const SizedBox(height: 50),
                        _buildModeDropdown(),
                      ],
                    ),
                  ),
                ),
                // No remarks text field here
                const SizedBox(height: 50), // Add some spacing
              ],
            ),
          ),
          const SizedBox(
              height:
                  20), // Added space between the container card and the buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () async {
                  print('Current step: $currentStep'); // Debugging print
                  if (currentStep == 0) {
                    // Change this to 0 for STEP 1
                    print('Showing dialog'); // Debugging print
                    bool? shouldDiscard = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Discard or Keep Changes?'),
                          content: const Text(
                              'Do you want to discard or keep your changes?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Keep Changes'),
                              onPressed: () async {
                                await _saveFormState(); // Save form state
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text('Discard'),
                              onPressed: () {
                                setState(() {
                                  currentStep = 0; // Reset to the first step
                                  _clearFormState(); // Clear the saved form state
                                });
                                Navigator.of(context)
                                    .pop(true); // Navigate back
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (shouldDiscard ?? false) {
                      // Discard changes and navigate back
                      setState(() {
                        currentStep = 0; // Reset to the first step
                        _clearFormState(); // Clear the saved form state
                      });
                      Navigator.of(context).pop(); // Navigate back
                    } else {
                      // Keep changes and navigate back
                      Navigator.of(context).pop();
                    }
                  } else {
                    setState(() {
                      currentStep--;
                    });
                  }
                },
                backgroundColor: myCustomButtonColor,
                child: Icon(Icons.arrow_back, color: myCustomButtonTextColor),
              ),
              FloatingActionButton(
                onPressed: () {
                  // Validation check for selected mode
                  if (selectedMode == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a mode')),
                    );
                    return;
                  }
                  setState(() {
                    currentStep++;
                  });
                },
                backgroundColor: myCustomButtonColor,
                child: Icon(Icons.add, color: myCustomButtonTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white
                      .withOpacity(0.5), // Added opacity for glass effect
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 23, 128, 23)
                          .withOpacity(0.5), // Added shadow for depth
                      spreadRadius: -2.0,
                      blurRadius: 4.0,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'How long will this activity take?',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      child: _buildTextField(durationController, 'Duration'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Added height spacing
            ],
          ),
        ),
        const SizedBox(height: 20), // Added height spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: () async {
                if (currentStep == 0) {
                  bool? shouldDiscard = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Discard or Keep Changes?'),
                        content: const Text(
                            'Do you want to discard or keep your changes?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Keep Changes'),
                            onPressed: () async {
                              await _saveFormState(); // Save form state
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Discard'),
                            onPressed: () {
                              setState(() {
                                currentStep = 0; // Reset to the first step
                                _clearFormState(); // Clear the saved form state
                              });
                              Navigator.of(context).pop(true); // Navigate back
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (shouldDiscard ?? false) {
                    // Discard changes and navigate back
                    setState(() {
                      currentStep = 0; // Reset to the first step
                      _clearFormState(); // Clear the saved form state
                    });
                    Navigator.of(context).pop(); // Navigate back
                  } else {
                    // Keep changes and navigate back
                    Navigator.of(context).pop();
                  }
                } else {
                  setState(() {
                    currentStep--;
                  });
                }
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.arrow_back, color: myCustomButtonTextColor),
            ),
            FloatingActionButton(
              onPressed: () {
                _viewAllData(); // Method to view all entered data
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.remove_red_eye_outlined,
                  color: myCustomButtonTextColor),
            ),
            FloatingActionButton(
              onPressed: () {
                // Validation check for duration
                if (durationController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a duration')),
                  );
                  return;
                }
                setState(() {
                  currentStep++;
                });
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.arrow_forward, color: myCustomButtonTextColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitiesPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What activity/ies will my students do?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color:
                          Colors.white.withOpacity(0.5), // Added glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _buildTextField(activitiesController, 'Activities'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: _buildAddButton('Add Activity', () {
                      setState(() {
                        addedActivities.add(activitiesController.text);
                        activitiesController.clear();
                      });
                      print(addedActivities);
                    }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Center(
                    child: Text(
                      'Activity List',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: _buildList(addedActivities, (index) {
                      setState(() {
                        addedActivities.removeAt(index);
                      });
                    }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Notes/Remarks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color:
                          Colors.white.withOpacity(0.5), // Added glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _buildTextField(remarksActivityController,
                        'Remarks'), // Updated to use new controller
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Added height spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentStep--;
                });
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.arrow_back, color: myCustomButtonTextColor),
            ),
            FloatingActionButton(
              onPressed: () {
                _viewAllData(); // Method to view all entered data
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.remove_red_eye_outlined,
                  color: myCustomButtonTextColor),
            ),
            FloatingActionButton(
              onPressed: () {
                // Validation check for activities
                if (addedActivities.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please add at least one activity')),
                  );
                  return;
                }
                setState(() {
                  currentStep++;
                });
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.arrow_forward, color: myCustomButtonTextColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLessonsPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What two(2) method cards will students use?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white
                          .withOpacity(0.5), // Added opacity for glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5), // Added shadow for depth
                          spreadRadius: -2.0,
                          blurRadius: 4.0,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          child: _buildLessonDropdown(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // Added height spacing
                  Center(
                    child: _buildAddButton('Add Lesson', _addLesson),
                  ),
                  const SizedBox(height: 10), // Added height spacing
                  const Text(
                    'Method List',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: _buildList(
                        selectedLessons
                            .map((lesson) => lesson['cards_title'] as String)
                            .toList(), (index) {
                      setState(() {
                        selectedLessons.removeAt(index);
                      });
                    }),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Notes/Remarks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white
                          .withOpacity(0.5), // Added opacity for glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5), // Added shadow for depth
                          spreadRadius: -2.0,
                          blurRadius: 4.0,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          child: _buildTextField(remarksLessonController,
                              'Remarks'), // Updated to use new controller
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Added height spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: () async {
                print('Current step: $currentStep'); // Debugging print
                if (currentStep == 0) {
                  // Change this to 0 for STEP 1
                  print('Showing dialog'); // Debugging print
                  bool? shouldDiscard = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Discard or Keep Changes?'),
                        content: const Text(
                            'Do you want to discard or keep your changes?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Keep Changes'),
                            onPressed: () async {
                              await _saveFormState(); // Save form state
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Discard'),
                            onPressed: () {
                              setState(() {
                                currentStep = 0; // Reset to the first step
                                _clearFormState(); // Clear the saved form state
                              });
                              Navigator.of(context).pop(true); // Navigate back
                            },
                          ),
                        ],
                      );
                    },
                  );
                  if (shouldDiscard ?? false) {
                    // Discard changes and navigate back
                    setState(() {
                      currentStep = 0; // Reset to the first step
                      _clearFormState(); // Clear the saved form state
                    });
                    Navigator.of(context).pop(); // Navigate back
                  } else {
                    // Keep changes and navigate back
                    Navigator.of(context).pop();
                  }
                } else {
                  setState(() {
                    currentStep--;
                  });
                }
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.arrow_back, color: myCustomButtonTextColor),
            ),
            FloatingActionButton(
              onPressed: () {
                _viewAllData(); // Method to view all entered data
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.remove_red_eye_outlined,
                  color: myCustomButtonTextColor),
            ),
            FloatingActionButton(
              onPressed: () {
                // Validation check for lessons
                if (selectedLessons.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please add at least one lesson')),
                  );
                  return;
                }
                setState(() {
                  currentStep++;
                });
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.arrow_forward, color: myCustomButtonTextColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutputsPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What outputs will my students produce?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white
                          .withOpacity(0.5), // Added opacity for glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5), // Added shadow for depth
                          spreadRadius: -2.0,
                          blurRadius: 4.0,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          child: _buildTextField(outputsController, 'Outputs'),
                        ),
                        const SizedBox(height: 10), // Added height spacing
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // Added height spacing
                  Center(
                    child: _buildAddButton('Add Output', () {
                      setState(() {
                        addedOutputs.add(outputsController.text);
                        outputsController.clear();
                      });
                    }),
                  ),
                  const SizedBox(height: 10), // Added height spacing
                  const Text(
                    'Output List',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: _buildList(addedOutputs, (index) {
                      setState(() {
                        addedOutputs.removeAt(index);
                      });
                    }),
                  ),
                  const SizedBox(height: 10), // Added height spacing
                  const Text(
                    'Notes/Remarks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white
                          .withOpacity(0.5), // Added opacity for glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5), // Added shadow for depth
                          spreadRadius: -2.0,
                          blurRadius: 4.0,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          child: _buildTextField(remarksOutputController,
                              'Remarks'), // Updated to use new controller
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Added height spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentStep--;
                });
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.arrow_back, color: myCustomButtonTextColor),
            ),
            FloatingActionButton(
              onPressed: () {
                _viewAllData(); // Method to view all entered data
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.remove_red_eye_outlined,
                  color: myCustomButtonTextColor),
            ),
            FloatingActionButton(
              onPressed: () {
                // Validation check for outputs
                if (addedOutputs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please add at least one output')),
                  );
                  return;
                }
                setState(() {
                  currentStep++;
                });
              },
              backgroundColor: myCustomButtonColor,
              child: Icon(Icons.arrow_forward, color: myCustomButtonTextColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructionsPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What instructions will I give my students?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white
                          .withOpacity(0.5), // Added opacity for glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5), // Added shadow for depth
                          spreadRadius: -2.0,
                          blurRadius: 4.0,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          child: _buildTextField(
                              instructionsController, 'Instructions'),
                        ),
                        const SizedBox(height: 10), // Added height spacing
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // Added height spacing for button
                  Center(
                    child: _buildAddButton('Add Instruction', () {
                      setState(() {
                        addedInstructions.add(instructionsController.text);
                        instructionsController.clear();
                      });
                    }),
                  ),
                  const SizedBox(height: 10), // Added height spacing for list
                  const Text(
                    'Instruction List',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: _buildList(addedInstructions, (index) {
                      setState(() {
                        addedInstructions.removeAt(index);
                      });
                    }),
                  ),
                  const SizedBox(height: 20), // Added height spacing
                  // Container for 'Notes/Remarks'
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color:
                          Colors.white.withOpacity(0.5), // Added glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes/Remarks',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          child: _buildTextField(remarksInstructionController,
                              'Remarks'), // Updated to use new controller
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Added height spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentStep--;
                });
              },
              backgroundColor: myCustomButtonColor,
              shape: const CircleBorder(),
              child: Icon(Icons.arrow_back,
                  color: myCustomButtonTextColor), // Changed to circular button
            ),
            FloatingActionButton(
              onPressed: () {
                _viewAllData(); // Method to view all entered data
              },
              backgroundColor: myCustomButtonColor,
              shape: const CircleBorder(),
              child: Icon(Icons.remove_red_eye_outlined,
                  color: myCustomButtonTextColor), // Changed to circular button
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentStep++;
                });
              },
              backgroundColor: myCustomButtonColor,
              shape: const CircleBorder(),
              child: Icon(Icons.arrow_forward,
                  color: myCustomButtonTextColor), // Changed to circular button
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoachDetailsPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How can I coach my students while doing this activity?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white
                          .withOpacity(0.5), // Added opacity for glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5), // Added shadow for depth
                          spreadRadius: -2.0,
                          blurRadius: 4.0,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          child: _buildTextField(
                              coachDetailsController, 'Coach Details'),
                        ),
                        const SizedBox(height: 10), // Added height spacing
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // Added height spacing
                  Center(
                    child: _buildAddButton('Add Coach Detail', () {
                      setState(() {
                        addedCoachDetails.add(coachDetailsController.text);
                        coachDetailsController.clear();
                      });
                    }),
                  ),
                  const SizedBox(height: 10), // Added height spacing
                  const Text(
                    'Coaching List',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: _buildList(addedCoachDetails, (index) {
                      setState(() {
                        addedCoachDetails.removeAt(index);
                      });
                    }),
                  ),
                  const SizedBox(height: 10), // Added height spacing
                  const Text(
                    'Notes/Remarks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white
                          .withOpacity(0.5), // Added opacity for glass effect
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 23, 128, 23)
                              .withOpacity(0.5), // Added shadow for depth
                          spreadRadius: -2.0,
                          blurRadius: 4.0,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          child: _buildTextField(remarksCoachDetailsController,
                              'Remarks'), // Updated to use new controller
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Added height spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentStep--;
                });
              },
              backgroundColor: myCustomButtonColor,
              shape: const CircleBorder(),
              child: Icon(Icons.arrow_back,
                  color: myCustomButtonTextColor), // Changed to circular button
            ),
            FloatingActionButton(
              onPressed: () {
                _viewAllData(); // Method to view all entered data
              },
              backgroundColor: myCustomButtonColor,
              shape: const CircleBorder(),
              child: Icon(Icons.remove_red_eye_outlined,
                  color: myCustomButtonTextColor), // Changed to circular button
            ),
            FloatingActionButton(
              onPressed: () {
                _submitAll(); // Submit all data
              },
              backgroundColor: myCustomButtonColor,
              shape: const CircleBorder(),
              child: Icon(Icons.check_circle_outline,
                  color: myCustomButtonTextColor), // Changed to circular button
            ),
          ],
        ),
      ],
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
        backgroundColor: myCustomButtonColor,
        minimumSize: const Size(100, 40), // Set the button size
      ),
      child: Text(
        label,
        style: TextStyle(color: myCustomButtonTextColor),
      ),
    );
  }

  Widget _buildList(List<String> items, Function(int) onRemove) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        TextEditingController itemController =
            TextEditingController(text: items[index]);

        return ListTile(
          title: Text(items[index]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Edit Item'),
                        content: TextField(
                          controller: itemController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Save'),
                            onPressed: () {
                              setState(() {
                                items[index] = itemController.text;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onRemove(index),
              ),
            ],
          ),
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
          (lesson) =>
              lesson['back_cards_header_id'].toString() == selectedLesson,
          orElse: () => {
            'cards_title': 'Unknown',
            'back_cards_header_id': selectedLesson
          },
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

  Future<Map<String, dynamic>> _collectAllData() async {
    return {
      'project': {
        'project_userId': widget.initialData['project_userId'],
        'project_subject_code': widget.initialData['project_subject_code'],
        'project_subject_description':
            widget.initialData['project_subject_description'],
        'project_title': widget.initialData['project_title'],
        'project_description': widget.initialData['project_description'],
        'project_start_date': widget.initialData['project_start_date'],
        'project_end_date': widget.initialData['project_end_date'],
      },
      'mode': {
        'project_modules_projectId': widget.initialData['projectId'].toString(),
        'project_modules_masterId': selectedMode,
      },
      'duration': {
        'activities_header_modulesId': lastInsertedModeId?.toString(),
        'activities_header_duration': durationController.text,
        'duration_remarks': remarksDurationController.text,
      },
      'activity': {
        'activities_details_remarks': remarksActivityController.text,
        'activities_details_content': jsonEncode(addedActivities),
        'activities_details_headerId': lastInsertedDurationId?.toString(),
      },
      'cards': selectedLessons
          .map((lesson) => {
                'project_cards_cardId':
                    lesson['back_cards_header_id'].toString(),
                'project_cards_modulesId': lastInsertedModeId?.toString(),
                'project_cards_remarks': remarksLessonController.text,
              })
          .toList(),
      'outputs': {
        'outputs_moduleId': lastInsertedModeId?.toString(),
        'outputs_remarks': remarksOutputController.text,
        'outputs_content': jsonEncode(addedOutputs),
      },
      'instructions': {
        'instruction_remarks': remarksInstructionController.text,
        'instruction_modulesId': lastInsertedModeId?.toString(),
        'instruction_content': jsonEncode(addedInstructions),
      },
      'coachDetails': {
        'coach_detail_coachheaderId': '1',
        'coach_detail_content': jsonEncode(addedCoachDetails),
        'coach_detail_remarks': remarksCoachDetailsController.text,
      },
    };
  }

  Future<void> _submitAll() async {
    try {
      final allData = await _collectAllData();

      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addAllData',
        'json': jsonEncode(allData),
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
          // Clear all form data
          print('datas: $decodedData');
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('empathyProjectFormData');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset to the mode step
          setState(() {
            currentStep = 0;
          });
        } else {
          // Show error dialog for existing module
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Module Already Exists'),
                content: Text(decodedData['message'] ?? 'An error occurred'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        throw Exception('Failed to submit data: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveFormState() async {
    final prefs = await SharedPreferences.getInstance();
    final formData = {
      'selectedMode': selectedMode,
      'duration': durationController.text,
      'activities': jsonEncode(addedActivities),
      'selectedLessons': jsonEncode(selectedLessons),
      'outputs': jsonEncode(addedOutputs),
      'instructions': jsonEncode(addedInstructions),
      'coachDetails': jsonEncode(addedCoachDetails),
      // Save remarks
      'remarksDuration': remarksDurationController.text,
      'remarksActivity': remarksActivityController.text,
      'remarksLesson': remarksLessonController.text,
      'remarksOutput': remarksOutputController.text,
      'remarksInstruction': remarksInstructionController.text,
      'remarksCoachDetails': remarksCoachDetailsController.text,
    };

    await prefs.setString('empathyProjectFormData', jsonEncode(formData));
    print('Form state saved successfully');
  }

  Future<void> _loadFormState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('empathyProjectFormData');

    if (savedData != null) {
      final formData = jsonDecode(savedData);
      setState(() {
        selectedMode = formData['selectedMode'];
        durationController.text = formData['duration'];
        addedActivities = List<String>.from(jsonDecode(formData['activities']));
        selectedLessons = List<Map<String, dynamic>>.from(
            jsonDecode(formData['selectedLessons']));
        addedOutputs = List<String>.from(jsonDecode(formData['outputs']));
        addedInstructions =
            List<String>.from(jsonDecode(formData['instructions']));
        addedCoachDetails =
            List<String>.from(jsonDecode(formData['coachDetails']));
        // Load remarks
        remarksDurationController.text = formData['remarksDuration'];
        remarksActivityController.text = formData['remarksActivity'];
        remarksLessonController.text = formData['remarksLesson'];
        remarksOutputController.text = formData['remarksOutput'];
        remarksInstructionController.text = formData['remarksInstruction'];
        remarksCoachDetailsController.text = formData['remarksCoachDetails'];
      });
    }
  }

  void _viewAllData() {
    // Show a dialog to display all entered data in a more presentable way
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Added to List',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Colors.green),
                  title: Text('Activities: ${addedActivities.join(', ')}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Colors.green),
                  title: Text('Outputs: ${addedOutputs.join(', ')}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Colors.green),
                  title: Text('Instructions: ${addedInstructions.join(', ')}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Colors.green),
                  title: Text('Coach Details: ${addedCoachDetails.join(', ')}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                // Add more data as needed
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearFormState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('empathyProjectFormData');
    print('Form state cleared successfully');
  }
}
