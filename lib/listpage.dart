import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:design/update-empaproject.dart';
import 'package:excel_dart/excel_dart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map<String, dynamic>> folders = [];

  @override
  void initState() {
    super.initState();
    fetchFolders(); // Ensure this method is called to fetch folders
  }

  Future<void> fetchFolders() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/masterlist.php'),
        body: {'operation': 'getFolder'},
      );
      print("FOLDERS FETCH: " + response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['folders'] != null && data['folders'] is List) {
          setState(() {
            folders = List<Map<String, dynamic>>.from(data['folders']
                .map((item) => {
                      'folder_id': item['id'] ?? '',
                      'project_subject_code':
                          item['project_subject_code'] ?? '',
                      'project_subject_description':
                          item['project_subject_description'] ?? '',
                      'project_title': item['project_title'] ?? '',
                      'project_description': item['project_description'] ?? '',
                      'project_start_date': item['project_start_date'] ?? '',
                      'project_end_date': item['project_end_date'] ?? '',
                      'module_master_name': item['module_master_name'] ?? '',
                      'activities_details_content':
                          item['activities_details_content'] ?? '',
                      'activities_header_duration':
                          item['activities_header_duration'] ?? '',
                      'cards_title': item['cards_title'] ?? '',
                      'outputs_content': item['outputs_content'] ?? '',
                      'instruction_content': item['instruction_content'] ?? '',
                      'coach_detail_content':
                          item['coach_detail_content'] ?? '',
                      'project_cardsId': item['project_cardsId'] is List
                          ? item['project_cardsId']
                          : [],
                      'cards_content': item['cards_content'] ?? '',
                      'back_cards_header_title':
                          item['back_cards_header_title'] ?? '',
                      'back_content_title': item['back_content_title'] ?? '',
                      'back_content': item['back_content'] ?? '',
                      'projectId': item['projectId'] ?? '',
                      'back_cards_header_frontId':
                          item['back_cards_header_frontId'] ?? '',
                      'activities_details_remarks':
                          item['activities_details_remarks'] ?? '',
                      'coach_detail_renarks':
                          item['coach_detail_renarks'] ?? '',
                      'outputs_remarks': item['outputs_remarks'] ?? '',
                      'project_cards_remarks':
                          item['project_cards_remarks'] ?? '',
                      'instruction_remarks': item['instruction_remarks'] ?? '',
                    })
                .toList());
          });

          // New print statement to show the number of project_cardsId fetched
          print(
              'Number of project_cardsId fetched: ${folders.map((folder) => folder['project_cardsId'].length).reduce((a, b) => a + b)}');

          // Print the fetched details
          print('Fetched Folder Details:');
          for (var folder in folders) {
            print('Folder ID: ${folder['folder_id']}');
            print('Project Title: ${folder['project_title']}');
            print('Project code: ${folder['project_subject_code']}');
            print(
                'Project Description: ${folder['project_subject_description']}');
            print('project description: ${folder['project_description']}');
            print('project start: ${folder['project_start_date']}');
            print('project end: ${folder['project_end_date']}');
            print('Module Master Name: ${folder['module_master_name']}');
            print(
                'Activities Details: ${folder['activities_details_content']}');
            print('Card Title: ${folder['cards_title']}');
            print('Outputs Content: ${folder['outputs_content']}');
            print('Instruction Content: ${folder['instruction_content']}');
            print('Coach Detail Content: ${folder['coach_detail_content']}');
            print('Project Cards ID: ${folder['project_cardsId']}');
            print(
                'back_cards_header_title: ${folder['back_cards_header_title']}');
            print('back_content_title: ${folder['back_content_title']}');
            print('Project ID: ${folder['projectId']}');
            print(
                'Back Cards Header Front ID: ${folder['back_cards_header_frontId']}');
            print('---');
          }
        } else {
          print('Invalid data format. Response: ${response.body}');
          throw Exception('Invalid data format: ${response.body}');
        }
      } else {
        // Improved error handling
        throw Exception(
            'Failed to load folders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching folders: $e');
      // Show a more user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching folders: ${e.toString()}')),
      );
    }
  }

  Future<void> _createFolder() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    TextEditingController myController = TextEditingController();
    String textToInclude = myController.text;
    final formKey = GlobalKey<FormState>();

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    }
  }

  void _onFolderTap(Map<String, dynamic> folder) {
    // New print statement to show the number of project_cardsId for the tapped folder
    print(
        'Number of project_cardsId for folder ${folder['project_title']}: ${folder['project_cardsId']?.length ?? 0}');

    print('Folder tapped: ${folder['project_title']}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailPage(folder: folder),
      ),
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('My Folders',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                headerStyle:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                cellStyle: const pw.TextStyle(fontSize: 12),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
                headerHeight: 25,
                cellHeight: 40,
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                },
                data: <List<String>>[
                  <String>[
                    'Folder Name',
                    'Module',
                    'Project Code',
                    'Project Description',
                    'Start Date',
                    'End Date'
                  ],
                  ...folders.map((folder) => [
                        folder['project_title'] ?? 'Unnamed Folder',
                        folder['module_master_name'] ?? 'Unknown module',
                        folder['project_subject_code'] ?? 'No code',
                        folder['project_subject_description'] ??
                            'No description',
                        folder['project_start_date'] ?? 'No start date',
                        folder['project_end_date'] ?? 'No end date',
                      ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    try {
      if (kIsWeb) {
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'my_folders.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
      // Use the global key to show the SnackBar
      if (scaffoldMessengerKey.currentState?.mounted ?? false) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('PDF generated successfully')),
        );
      }
    } catch (e) {
      print('Error generating PDF: $e');
      // Use the global key to show the SnackBar
      if (scaffoldMessengerKey.currentState?.mounted ?? false) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey, // Set the key here
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Project Folders',
              style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.w600)),
          elevation: 0,
          backgroundColor: Colors.teal,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf,
                  color: Color.fromARGB(255, 3, 3, 3)),
              onPressed: () => _generatePDF(),
              tooltip: 'Generate PDF',
            ),
          ],
        ),
        body: folders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No folders available',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontFamily: 'Roboto'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[100]!, Colors.blue[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.folder, color: Colors.white),
                        ),
                        title: Text(
                          folders[index]['project_title'] ?? 'Unnamed Folder',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                        subtitle: Text(
                          'Module: ${folders[index]['module_master_name'] ?? 'Unknown module'}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'Roboto'),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.blue),
                        onTap: () => _onFolderTap(folders[index]),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class FolderDetailPage extends StatefulWidget {
  final Map<String, dynamic> folder;

  const FolderDetailPage({super.key, required this.folder});

  @override
  _FolderDetailPageState createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  List<Map<String, dynamic>>? cardData; // Change to List to hold multiple cards
  List<Map<String, dynamic>>? moduleData;
  List<Map<String, dynamic>>? ActData;
  List<Map<String, dynamic>>? InsData;
  List<Map<String, dynamic>>? OutputData;
  List<Map<String, dynamic>>? CoachData;

  @override
  void initState() {
    super.initState();
    _fetchCardData();
    _fetchProject();
  }

  Future<void> _fetchCardData() async {
    final projectId = widget.folder['projectId'];
    final projectCardsIds =
        widget.folder['project_cardsId']; // Get the list of project_cardsId

    print(
        'Fetching card data for projectId: $projectId, projectCardsIds: $projectCardsIds');

    try {
      // Make the HTTP POST request to your API
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/masterlist.php'),
        body: {
          'operation': 'getCards1',
          'projectId': projectId.toString(),
          'cardIds': json.encode(projectCardsIds), // Send the list of card IDs
        },
      );

      // Check if the response status is OK (HTTP 200)
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Check if the response is a map (expected JSON format)
        if (data is Map<String, dynamic>) {
          if (data['success'] == true && data['data'] != null) {
            setState(() {
              cardData = List<Map<String, dynamic>>.from(
                  data['data']); // Store multiple cards
            });
            print('Fetched Card Data:');
            cardData?.forEach((card) {
              print('Card Title: ${card['cards_title']}');
              print('Card Content: ${card['cards_content']}');
            });
          } else {
            print('No data found');
            setState(() {
              cardData = null;
            });
          }
        } else {
          // Handle unexpected data types
          print('Unexpected data format: ${data.runtimeType}');
          print('Data content: $data');
          setState(() {
            cardData = null;
          });
        }
      } else {
        // Log failure to fetch data with response details
        print('Failed to fetch card data');
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          cardData = null;
        });
      }
    } catch (e) {
      // Handle and log exceptions
      print('Database error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database error occurred: $e')),
      );
    }
  }

  Future<void> _fetchProject() async {
    final projectId = widget.folder['projectId'];

    // Log the projectId to ensure it's being retrieved correctly
    print('Fetching project data for projectId: $projectId');

    try {
      // Make the HTTP POST request to your API
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/masterlist.php'),
        body: {
          'operation': 'getFolders', // Ensure this operation is correct
          'projectId':
              projectId.toString(), // Ensure projectId is sent as a string
        },
      );

      // Log the response body for debugging
      print('Response body: ${response.body}');

      // Check if the response status is OK (HTTP 200)
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Check if the response is a map (expected JSON format)
        if (data is Map<String, dynamic>) {
          if (data['success'] == true && data['folders'] != null) {
            setState(() {
              moduleData = List<Map<String, dynamic>>.from(data['folders']);
            });
            print('Fetched Project Data:');
            moduleData?.forEach((module) {
              print('Module Name: ${module['module_master_name']}');
              print('Module Details: ${module['module_master_name']}');
            });
          } else {
            print('No data found or success flag is false');
            setState(() {
              moduleData = null;
            });
          }
        } else {
          // Handle unexpected data types
          print('Unexpected data format: ${data.runtimeType}');
          print('Data content: $data');
          setState(() {
            moduleData = null;
          });
        }
      } else {
        // Log failure to fetch data with response details
        print('Failed to fetch project data');
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          moduleData = null;
        });
      }
    } catch (e) {
      // Handle and log exceptions
      print('Database error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database error occurred: $e')),
      );
    }
  }

  void _addLesson(BuildContext context) {
    print(
        'Add lesson tapped for folder: ${widget.folder['project_title'] ?? 'Unnamed Folder'}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Add lesson functionality to be implemented')),
    );
  }

  Future<void> _generateExcel(BuildContext context) async {
    final Excel excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.setColWidth(0, 50);
    sheet.setColWidth(1, 110);
    sheet.setColWidth(2, 40);

    sheet.appendRow(['', 'MY DESIGN THINKING PLAN', '']);
    sheet.appendRow(
        ['Project', widget.folder['project_title'] ?? 'Unnamed Project', '']);
    sheet.appendRow([
      'Project Description',
      widget.folder['project_subject_description'] ?? 'No description',
      ''
    ]);
    sheet.appendRow([
      'Start Date',
      widget.folder['project_start_date'] ?? 'No start date',
      ''
    ]);
    sheet.appendRow(
        ['End Date', widget.folder['project_end_date'] ?? 'No end date', '']);

    for (var module in moduleData ?? []) {
      sheet.appendRow([module['module_master_name'], '', 'NOTES/REMARKS']);
      sheet.appendRow([
        'What activities will my students do?',
        _filterData(module['activities_details_content']),
        _filterData(module['activities_details_remarks'])
      ]);

      final moduleCards = cardData
          ?.where(
              (card) => card['project_moduleId'] == module['project_moduleId'])
          .toList();
      if (moduleCards != null && moduleCards.isNotEmpty) {
        String cardsText =
            moduleCards.map((card) => '- ${card['cards_title']}').join('\n');
        sheet.appendRow([
          'What two (2) method cards will my students use?',
          cardsText,
          _filterData(widget.folder['project_cards_remarks'])
        ]);
      }

      sheet.appendRow([
        'How long will this activity take?',
        _filterData(module['activities_header_duration'])
      ]);

      sheet.appendRow([
        'What are the expected outputs?',
        _filterData(module['outputs_content']),
        _filterData(module['outputs_remarks'])
      ]);

      sheet.appendRow([
        'What instructions will I give my students?',
        _filterData(module['instruction_content']),
        _filterData(module['instruction_remarks'])
      ]);

      sheet.appendRow([
        'How can I coach my students while doing this activity?',
        _filterData(module['coach_detail_content']),
        _filterData(module['coach_detail_renarks'])
      ]);

      sheet.appendRow(['', '', '']);
    }

    try {
      if (kIsWeb) {
        final bytes = excel.encode();
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'folder_details.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/folder_details.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(excel.encode()!, flush: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel file saved to $filePath')),
        );
      }
    } catch (e) {
      print('Error generating Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate Excel: $e')),
      );
    }
  }

  // Helper function to format data in bullet form with new lines
  String _filterData(String? data) {
    if (data == null) {
      return '';
    }
    // Remove the array-like format and split into individual items
    List<String> items = data.replaceAll(RegExp(r'^\["|"\]$'), '').split('","');

    // Prepend a bullet point to each item and join them with new lines
    return items
        .map((item) => '- $item')
        .join('\n\n'); // Added extra \n for 1.5 spacing
  }

  Future<void> _generatePDF(BuildContext context) async {
    final pdf = pw.Document();

    // Add the cover page with project details
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Center(
                  child: pw.Text('MY DESIGN THINKING PLAN',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  _buildPdfTableRow(
                      'Project', widget.folder['project_title'], null),
                  _buildPdfTableRow('Project Description',
                      widget.folder['project_subject_description'], null),
                  _buildPdfTableRow(
                      'Start Date', widget.folder['project_start_date'], null),
                  _buildPdfTableRow(
                      'End Date', widget.folder['project_end_date'], null),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Add each module on a separate page
    for (var module in moduleData ?? []) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Module Title
                pw.Text(
                  module['module_master_name'] ?? '',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),

                // Module Content Table
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Field',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Details',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Remarks',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Activities
                    _buildPdfTableRow(
                      'What activities will my students do?',
                      _filterData(module['activities_details_content']),
                      _filterData(module['activities_details_remarks']),
                    ),
                    // Method Cards
                    _buildPdfTableRow(
                      'What two (2) method cards will my students use?',
                      cardData
                          ?.where((card) =>
                              card['project_moduleId'] ==
                              module['project_moduleId'])
                          .map((card) => '- ${card['cards_title']}')
                          .join('\n'),
                      _filterData(widget.folder['project_cards_remarks']),
                    ),
                    // Duration
                    _buildPdfTableRow(
                      'How long will this activity take?',
                      _filterData(module['activities_header_duration']),
                      null,
                    ),
                    // Outputs
                    _buildPdfTableRow(
                      'What are the expected outputs?',
                      _filterData(module['outputs_content']),
                      _filterData(module['outputs_remarks']),
                    ),
                    // Instructions
                    _buildPdfTableRow(
                      'What instructions will I give my students?',
                      _filterData(module['instruction_content']),
                      _filterData(module['instruction_remarks']),
                    ),
                    // Coaching
                    _buildPdfTableRow(
                      'How can I coach my students while doing this activity?',
                      _filterData(module['coach_detail_content']),
                      _filterData(module['coach_detail_renarks']),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    try {
      if (kIsWeb) {
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download',
              '${widget.folder['project_title'] ?? 'project'}_details.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully')),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }

  // Helper method for building PDF table rows
  pw.TableRow _buildPdfTableRow(
      String field, String? content, String? remarks) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(field),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            content ?? 'Not specified',
            style: const pw.TextStyle(
              lineSpacing: 1.5, // Line spacing for content
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            remarks ?? '-',
            style: const pw.TextStyle(
              lineSpacing: 1.5, // Line spacing for remarks
            ),
          ),
        ),
      ],
    );
  }

  void _showFolderDetails(BuildContext context) {
    final projectId = widget.folder['projectId'];
    print('ProjectID: $projectId');
    final cardTitles = cardData
            ?.where((card) => card['projectId'] == projectId)
            .map((card) => card['cards_title'])
            .toList() ??
        [];

    final projectModule = moduleData
            ?.where((module) => module['projectId'] == projectId)
            .map((module) => module['module_master_name'])
            .toList() ??
        [];
    final projectAct = moduleData
            ?.where((module) => module['projectId'] == projectId)
            .map((module) => module['activities_details_content'])
            .toList() ??
        [];
    final projectIns = moduleData
            ?.where((module) => module['projectId'] == projectId)
            .map((module) => module['instruction_content'])
            .toList() ??
        [];
    final projectOuput = moduleData
            ?.where((module) => module['projectId'] == projectId)
            .map((module) => module['outputs_content'])
            .toList() ??
        [];
    final projectCoach = moduleData
            ?.where((module) => module['projectId'] == projectId)
            .map((module) => module['coach_detail_content'])
            .toList() ??
        [];
    final String cardTitlesString = cardTitles.join(', ');
    final String projectModuleString = projectModule.join(', ');
    final String projectActString = projectAct.join(', ');
    final String projectInsString = projectIns.join(', ');
    final String projectOuputString = projectOuput.join(', ');
    final String projectCoachString = projectCoach.join(', ');

    final remarks = [
      widget.folder['activities_details_remarks'] ?? 'No remarks',
      widget.folder['coach_detail_renarks'] ?? 'No remarks',
      widget.folder['outputs_remarks'] ?? 'No remarks',
      widget.folder['project_cards_remarks'] ?? 'No remarks',
      widget.folder['instruction_remarks'] ?? 'No remarks',
    ].join('\n');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5E6D3).withOpacity(0.9),
          title: Text(
            widget.folder['project_title'] ?? 'Unnamed Folder',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Project Code'),
                      subtitle: Text(
                          widget.folder['project_subject_code'] ?? 'No code'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showUpdateDialog(context, 'project_subject_code'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Project Description'),
                      subtitle: Text(
                          widget.folder['project_subject_description'] ??
                              'No description'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUpdateDialog(
                            context, 'project_subject_description'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(widget.folder['project_start_date'] ??
                          'No start date'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showUpdateDialog(context, 'project_start_date'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(
                          widget.folder['project_end_date'] ?? 'No end date'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showUpdateDialog(context, 'project_end_date'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Module Names'),
                      subtitle: Text(
                        projectModule.isNotEmpty
                            ? projectModule
                                .map((name) => '- $name')
                                .join('\n\n') // Added extra \n for 1.5 spacing
                            : 'No modules available',
                        style:
                            const TextStyle(height: 1.5), // Added line height
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showUpdateDialog(context, 'module_master_name'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Activity'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            projectAct.isNotEmpty
                                ? projectAct
                                    .map((title) =>
                                        '- ${title.replaceAll(RegExp(r'^\["|"\]$'), '')}')
                                    .join(
                                        '\n\n') // Added extra \n for 1.5 spacing
                                : 'No activities available',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              height: 1.5, // Added line height
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const Text(
                            'Remarks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            widget.folder['activities_details_remarks'] ??
                                'No remarks',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showUpdateDialog(
                            context, 'activities_details_content'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Output'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            projectOuput.isNotEmpty
                                ? projectOuput
                                    .map((title) =>
                                        '- ${title.replaceAll(RegExp(r'^\["|"\]$'), '')}')
                                    .join(
                                        '\n\n') // Added extra \n for 1.5 spacing
                                : 'No outputs available',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              height: 1.5, // Added line height
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const Text(
                            'Remarks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            widget.folder['outputs_remarks'] ?? 'No remarks',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showUpdateDialog(context, 'outputs_content'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Instruction'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            projectIns.isNotEmpty
                                ? projectIns
                                    .map((title) =>
                                        '- ${title.replaceAll(RegExp(r'^\["|"\]$'), '')}')
                                    .join(
                                        '\n\n') // Added extra \n for 1.5 spacing
                                : 'No instructions available',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              height: 1.5, // Added line height
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const Text(
                            'Remarks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            widget.folder['instruction_remarks'] ??
                                'No remarks',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showUpdateDialog(context, 'instruction_content'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Coach Detail'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            projectCoach.isNotEmpty
                                ? projectCoach
                                    .map((title) =>
                                        '- ${title.replaceAll(RegExp(r'^\["|"\]$'), '')}')
                                    .join(
                                        '\n\n') // Added extra \n for 1.5 spacing
                                : 'No coach details available',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              height: 1.5, // Added line height
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                          const Text(
                            'Remarks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            widget.folder['coach_detail_renarks'] ??
                                'No remarks',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showUpdateDialog(context, 'coach_detail_content'),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text(
                        'Card Titles',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      subtitle: Text(
                        cardTitles.isNotEmpty
                            ? cardTitles
                                .map((title) => '- $title')
                                .join('\n\n') // Added extra \n for 1.5 spacing
                            : 'No cards available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          height: 1.5, // Added line height
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showUpdateDialog(context, 'cards_title'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _generatePDF(context),
              child: const Text('Generate PDF'),
            ),
            TextButton(
              onPressed: () => _generateExcel(context),
              child: const Text('Generate Excel'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to the UpdateProjectPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProjectPage(
                      initialData: widget.folder,
                    ),
                  ),
                );
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, String field) {
    TextEditingController controller = TextEditingController();

    if (field == 'project_start_date' || field == 'project_end_date') {
      // Use a date picker for date fields
      showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      ).then((pickedDate) {
        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          _updateData(field, formattedDate);
        }
      });
    } else {
      // Use a text field for other fields
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update $field'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter new $field'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _updateData(field, controller.text);
                  Navigator.of(context).pop();
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateData(String field, String newValue) async {
    String operation;
    switch (field) {
      case 'project_subject_description':
        operation = 'Subject';
        break;
      case 'project_start_date':
        operation = 'updateProjectStart';
        break;
      case 'End':
        operation = 'updateProjectEnd';
        break;
      case 'module_master_name':
        operation = 'updateModule';
        break;
      case 'activity':
        operation = 'updateActivity';
        break;
      case 'output':
        operation = 'updateOutput';
        break;
      case 'instruction':
        operation = 'updateInstruction';
        break;
      case 'coachDetail':
        operation = 'updateCoachDetail';
        break;
      default:
        operation = 'project'; // Default operation
    }

    // Log the operation and field being updated
    print('Attempting to update field: $field with operation: $operation');

    try {
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/updates.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'operation': operation,
          'json': jsonEncode({
            'project_id': widget.folder['projectId'],
            field: newValue,
          }),
        }),
      );

      if (response.statusCode == 200) {
        print('Update successful: ${response.body}');
        setState(() {
          widget.folder[field] = newValue;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Update successful')),
        );
      } else {
        print('Failed to update: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error during update: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder['project_title'] ?? 'Unnamed Folder'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showFolderDetails(context),
            tooltip: 'Show Details',
          ),
        ],
      ),
      body: cardData == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey[200], // Set a subtle background color
              child: PageView.builder(
                // Use PageView for swiping cards
                scrollDirection: Axis.horizontal,
                itemCount: cardData!.length,
                itemBuilder: (context, index) {
                  final card = cardData![index];
                  return Padding(
                    // Add padding around each card
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 24.0), // Adjust vertical spacing
                    child: ClipRRect(
                      // Clip the card to have rounded corners
                      borderRadius:
                          BorderRadius.circular(20), // Rounded corners
                      child: FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        speed: 1000,
                        front: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.blueAccent, Colors.purpleAccent],
                            ),
                            borderRadius:
                                BorderRadius.circular(20), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(
                                    16.0), // Add padding inside the card
                                child: Text(
                                  card['cards_title'] ?? 'No title',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        16.0), // Add padding for content
                                child: Text(
                                  card['cards_content'] ?? 'No content',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        back: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.purpleAccent, Colors.blueAccent],
                            ),
                            borderRadius:
                                BorderRadius.circular(20), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            // Make the back content scrollable
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    16.0), // Add padding inside the back card
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      card['back_content_title'] ??
                                          'No back title',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 24),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      card['back_content'] ?? 'No back content',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
