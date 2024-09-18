import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController coachHeaderController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    fetchModes();
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

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
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

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addActivity',
        'json': jsonEncode({
          'activities_details_remarks': 'Activity',
          'activities_details_content': activitiesController.text,
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
                .add({'type': 'Activity', 'value': activitiesController.text});
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

    String url = "http://localhost/design/lib/api/masterlist.php";
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

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addOutput',
        'json': jsonEncode({
          'outputs_moduleId': lastInsertedModeId.toString(),
          'outputs_remarks': 'Output',
          'outputs_content': outputsController.text,
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
                .add({'type': 'Output', 'value': outputsController.text});
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

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addInstruction',
        'json': jsonEncode({
          'instruction_remarks': 'Instruction',
          'instruction_modulesId': lastInsertedModeId.toString(),
          'instruction_content': instructionsController.text,
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
                {'type': 'Instruction', 'value': instructionsController.text});
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

  Future<void> addCoachHeader() async {
    if (lastInsertedModeId == null) {
      print('No mode ID available');
      return;
    }

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addCoachHeader',
        'json': jsonEncode({
          'coach_header_moduleId': lastInsertedModeId.toString(),
          'coach_header_duration': coachHeaderController.text,
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
          print('Coach Header added successfully');
          setState(() {
            lastInsertedCoachHeaderId = int.parse(decodedData['id']);
            currentStep++;
            allAddedData.add(
                {'type': 'Coach Header', 'value': coachHeaderController.text});
          });
        } else {
          print('Failed to add coach header: ${decodedData['error']}');
        }
      } else {
        throw Exception('Failed to add coach header: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding coach header: $e');
    }
  }

  Future<void> addCoachDetails() async {
    if (lastInsertedCoachHeaderId == null) {
      print('No coach header ID available');
      return;
    }

    try {
      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addCoachDetails',
        'json': jsonEncode({
          'coach_detail_coachheaderId': lastInsertedCoachHeaderId.toString(),
          'coach_detail_content': coachDetailsController.text,
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
            lastInsertedCoachHeaderId!,
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
              'value': coachDetailsController.text
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
      if (insertedIds.length < 8) {
        print(
            'Error: Not all required IDs are available. Current IDs: ${insertedIds.join(', ')}');
        return;
      }

      String url = "http://localhost/design/lib/api/masterlist.php";
      Map<String, String> requestBody = {
        'operation': 'addFolder',
        'json': jsonEncode({
          'projectId': widget.projectId.toString(),
          'project_moduleId': insertedIds[0].toString(),
          'activities_detailId': lastInsertedActivityId.toString(),
          'project_cardsId': insertedIds[3].toString(),
          'outputId': insertedIds[4].toString(),
          'instructionId': insertedIds[5].toString(),
          'coach_headerId': insertedIds[6].toString(),
          'coach_detailsId': insertedIds[7].toString(),
        }),
      };

      print('Adding to folder with IDs:');
      print('projectId: ${widget.projectId}');
      print('project_moduleId: ${insertedIds[0]}');
      print('activities_detailId: $lastInsertedActivityId');
      print('project_cardsId: ${insertedIds[3]}');
      print('outputId: ${insertedIds[4]}');
      print('instructionId: ${insertedIds[5]}');
      print('coach_headerId: ${insertedIds[6]}');
      print('coach_detailsId: ${insertedIds[7]}');

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData['success'] == true) {
          print('Added to folder successfully');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${currentStep + 1} of 8'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildCurrentStep(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (currentStep < 7) {
                    if (currentStep == 0) {
                      addMode();
                    } else if (currentStep == 1) {
                      addDuration();
                    } else if (currentStep == 2) {
                      addActivity();
                    } else if (currentStep == 3) {
                      // Save all selected lessons to databases
                      bool allCardsAdded = true;
                      for (var lesson in selectedLessons) {
                        try {
                          await addCard(lesson['cards_id'].toString());
                        } catch (e) {
                          print('Error adding card to database: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Error adding card to database: $e')),
                          );
                          allCardsAdded = false;
                          break;
                        }
                      }
                      if (allCardsAdded) {
                        setState(() {
                          allSelectedLessons.addAll(selectedLessons);
                          selectedLessons.clear();
                          currentStep++;
                          allAddedData.add(
                              {'type': 'Lessons', 'value': allSelectedLessons});
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add all cards')),
                        );
                      }
                    } else if (currentStep == 4) {
                      addOutput();
                    } else if (currentStep == 5) {
                      addInstruction();
                    } else if (currentStep == 6) {
                      addCoachHeader();
                    }
                  } else {
                    // Handle submission here
                    await addCoachDetails();
                    print('Submitting data');
                  }
                },
                child: Text(currentStep == 7 ? 'Submit' : 'Next'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryPage(
                        allAddedData: allAddedData,
                      ),
                    ),
                  );
                },
                child: Text('View Summary'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildModeStep();
      case 1:
        return _buildDurationStep();
      case 2:
        return _buildActivitiesStep();
      case 3:
        return _buildLessonStep();
      case 4:
        return _buildOutputsStep();
      case 5:
        return _buildInstructionsStep();
      case 6:
        return _buildCoachHeaderStep();
      case 7:
        return _buildCoachDetailsStep();
      default:
        return Container();
    }
  }

  Widget _buildModeStep() {
    return _buildStep(
      title: 'Mode',
      content: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: 'Select Mode',
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        items: modes.map((mode) {
          return DropdownMenuItem<String>(
            value: mode['module_master_id'].toString(),
            child: Text(mode['module_master_name']),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedMode = newValue;
            selectedLesson = null; // Reset selected lesson when mode changes
            if (newValue != null) {
              fetchLessons(newValue);
            }
          });
        },
      ),
    );
  }

  Widget _buildDurationStep() {
    return _buildStep(
      title: 'Duration',
      content: TextField(
        controller: durationController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: 'How long will it take?',
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        maxLines: 1,
      ),
    );
  }

  Widget _buildActivitiesStep() {
    return _buildStep(
      title: 'Activities',
      content: TextField(
        controller: activitiesController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: 'What activities will my students do?',
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildLessonStep() {
    return _buildStep(
      title: 'Lesson',
      content: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              labelText: 'Select a lesson',
              labelStyle: const TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            items: lessons.map((lesson) {
              return DropdownMenuItem<String>(
                value: lesson['cards_id'].toString(),
                child: Text(
                    '${lesson['cards_title']} (ID: ${lesson['cards_id'].toString()})'),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedLesson = newValue;
              });
            },
            value: selectedLesson,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (selectedLesson != null) {
                setState(() {
                  Map<String, dynamic> addedLesson = lessons.firstWhere(
                    (lesson) => lesson['cards_id'].toString() == selectedLesson,
                    orElse: () =>
                        {'cards_title': 'Unknown', 'cards_id': selectedLesson},
                  );
                  selectedLessons.add(addedLesson);
                  selectedLesson = null;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a lesson')),
                );
              }
            },
            child: Text('Add Lesson'),
          ),
          SizedBox(height: 20),
          Text('Selected Lessons:'),
          ListView.builder(
            shrinkWrap: true,
            itemCount: selectedLessons.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    selectedLessons[index]['cards_title'] ?? 'Unknown Title'),
                subtitle: Text(
                    'ID: ${selectedLessons[index]['cards_id'] ?? 'Unknown ID'}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      selectedLessons.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOutputsStep() {
    return _buildStep(
      title: 'Outputs',
      content: TextField(
        controller: outputsController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: 'What are the expected outputs?',
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildInstructionsStep() {
    return _buildStep(
      title: 'Instructions',
      content: TextField(
        controller: instructionsController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: 'What Instruction will I give to my students?',
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildCoachHeaderStep() {
    return _buildStep(
      title: 'Coach Header',
      content: TextField(
        controller: coachHeaderController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: 'Enter Coach Header',
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildCoachDetailsStep() {
    return _buildStep(
      title: 'Coach Details',
      content: TextField(
        controller: coachDetailsController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: 'Enter Coach Details',
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildStep({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        content,
      ],
    );
  }
}

class SummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> allAddedData;

  const SummaryPage({
    Key? key,
    required this.allAddedData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var data in allAddedData)
                if (data['type'] == 'Lessons')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['type']}:'),
                      for (var lesson in data['value'])
                        Text(
                            '  - ${lesson['cards_title']} (ID: ${lesson['cards_id']})'),
                      SizedBox(height: 10),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['type']}: ${data['value']}'),
                      SizedBox(height: 10),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
