import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';

import 'package:excel_dart/excel_dart.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Ensure this import is included for printing
import 'package:shadcn_ui/shadcn_ui.dart';

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

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('API Response: $data');

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
                          item['activities_details_remarks'],
                      'coach_detail_renarks': item['coach_detail_renarks'],
                      'outputs_remarks': item['outputs_remarks'],
                      'project_cards_remarks': item['project_cards_remarks'],
                      'instruction_remarks': item['instruction_remarks'],
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

  @override
  void initState() {
    super.initState();
    _fetchCardData();
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

  void _addLesson(BuildContext context) {
    // TODO: Implement lesson addition logic
    print(
        'Add lesson tapped for folder: ${widget.folder['project_title'] ?? 'Unnamed Folder'}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Add lesson functionality to be implemented')),
    );
  }

  void _showFolderDetails(BuildContext context) {
    // Gather all card titles for the same projectId
    final projectId = widget.folder['projectId'];
    final cardTitles = cardData
            ?.where((card) => card['projectId'] == projectId)
            .map((card) => card['cards_title'])
            .toList() ??
        [];

    final cardTitlesString = cardTitles.join(', '); // Join titles with a comma

    // New: Gather remarks for the folder
    final remarks = [
      widget.folder['activities_details_remarks'] ?? 'No remarks',
      widget.folder['coach_detail_renarks'] ?? 'No remarks',
      widget.folder['outputs_remarks'] ?? 'No remarks',
      widget.folder['project_cards_remarks'] ?? 'No remarks',
      widget.folder['instruction_remarks'] ?? 'No remarks',
    ].join('\n'); // Join remarks with a newline

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5E6D3)
              .withOpacity(0.9), // Pale sand color with opacity
          title: Text(
            widget.folder['project_title'] ?? 'Unnamed Folder',
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 24, // Increased font size
                fontWeight: FontWeight.bold), // Increased font size and bold
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width *
                0.8, // Set the width to 80% of the screen
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Replace Table with Column of Cards
                  Card(
                    child: ListTile(
                      title: const Text('Project Code'),
                      subtitle: Text(
                          widget.folder['project_subject_code'] ?? 'No code'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Project Description'),
                      subtitle: Text(
                          widget.folder['project_subject_description'] ??
                              'No description'),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(widget.folder['project_start_date'] ??
                          'No start date'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(
                          widget.folder['project_end_date'] ?? 'No end date'),
                    ),
                  ),

                  Card(
                    child: ListTile(
                      title: const Text('Module'),
                      subtitle: Text(
                          widget.folder['module_master_name'] ?? 'Unknown'),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        // Changed from Row to Column
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align items to the start
                        children: [
                          // Activity Title
                          const Text(
                            'Activity',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          // Activity Content
                          Text(
                            widget.folder['activities_details_content'] != null
                                ? widget.folder['activities_details_content']
                                    .split('\n')
                                    .map((activity) => '• $activity')
                                    .join('\n')
                                : 'No activity',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                          const SizedBox(
                              height: 10), // Add some space between sections
                          const Divider(), // Divider between Activity and Remarks
                          // Remarks Title
                          const Text(
                            'Remarks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          // Remarks Content
                          Text(
                            widget.folder['activities_details_remarks'] ??
                                'No remarks',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        // Changed from Row to Column
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align items to the start
                        children: [
                          // Output Title
                          const Text(
                            'Output',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          // Output Content
                          Text(
                            widget.folder['outputs_content'] != null
                                ? widget.folder['outputs_content']
                                    .split('\n')
                                    .map((output) => '• $output')
                                    .join('\n')
                                : 'No output',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                          const SizedBox(
                              height: 10), // Add some space between sections
                          const Divider(), // Divider between Output and Remarks
                          // Remarks Title
                          const Text(
                            'Remarks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          // Remarks Content
                          Text(
                            widget.folder['outputs_remarks'] ?? 'No remarks',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        // Changed from Row to Column
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align items to the start
                        children: [
                          // Instruction Title
                          const Text(
                            'Instruction',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          // Instruction Content
                          Text(
                            widget.folder['coach_detail_content'] != null
                                ? widget.folder['coach_detail_content']
                                    .split('\n')
                                    .map((coach) => '• $coach')
                                    .join('\n')
                                : 'No output',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                          const SizedBox(
                              height: 10), // Add some space between sections
                          const Divider(), // Divider between Instruction and Remarks
                          // Remarks Title
                          const Text(
                            'Remarks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          // Remarks Content
                          Text(
                            widget.folder['instruction_remarks'] ??
                                'No remarks',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        // Changed from Row to Column
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align items to the start
                        children: [
                          // Coach Detail Title
                          const Text(
                            'Coach Detail',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          // Coach Detail Content
                          Text(
                            widget.folder['coach_detail_content'] ??
                                'No coach detail',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                          const SizedBox(
                              height: 10), // Add some space between sections
                          const Divider(), // Divider for separation
                          // Remarks Title
                          const Text(
                            'Remarks',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          // Remarks Content
                          Text(
                            widget.folder['coach_detail_remarks'] ??
                                'No remarks', // Fixed typo in the key
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
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
                            ? cardTitles.map((title) => '• $title').join('\n')
                            : 'No cards available',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              // Increased padding around the button row
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Space buttons evenly
                children: [
                  ElevatedButton(
                    onPressed: () => _generateExcel(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6D0B3),
                      foregroundColor: Colors.black87,
                      minimumSize: const Size(100, 50), // Increased size
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10), // Increased padding
                    ),
                    child: const Text('Excel'),
                  ),
                  const SizedBox(width: 20), // Increased space between buttons
                  ElevatedButton(
                    onPressed: () => _generatePDF(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6D0B3),
                      foregroundColor: Colors.black87,
                      minimumSize: const Size(100, 50), // Increased size
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10), // Increased padding
                    ),
                    child: const Text(' PDF'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  TableRow _buildTableRow(String label, String value, String remarks) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: value.startsWith('[') && value.endsWith(']')
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (json.decode(value) as List<dynamic>)
                      .map((item) => Text('• $item',
                          style: const TextStyle(color: Colors.black87)))
                      .toList(),
                )
              : Text(value, style: const TextStyle(color: Colors.black87)),
        ),
        // New: Add a column for remarks
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(remarks, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Future<void> _generatePDF(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                      widget.folder['project_title'] ?? 'Unnamed Folder',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Generated on: $formattedDate',
                    style: pw.TextStyle(
                        fontSize: 12, fontStyle: pw.FontStyle.italic)),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    _buildPDFTableRow('Project Code:',
                        widget.folder['project_subject_code'] ?? 'No code'),
                    _buildPDFTableRow(
                        'Project Description:',
                        widget.folder['project_subject_description'] ??
                            'No description'),
                    _buildPDFTableRow('Start Date:',
                        widget.folder['project_start_date'] ?? 'No start date'),
                    _buildPDFTableRow('End Date:',
                        widget.folder['project_end_date'] ?? 'No end date'),
                    _buildPDFTableRow('Module:',
                        widget.folder['module_master_name'] ?? 'Unknown'),
                    _buildPDFTableRow(
                        'Activity:',
                        widget.folder['activities_details_content'] ??
                            'No activity'),
                    _buildPDFTableRow(
                        'Card:', widget.folder['cards_title'] ?? 'No card'),
                    _buildPDFTableRow('Output:',
                        widget.folder['outputs_content'] ?? 'No output'),
                    _buildPDFTableRow(
                        'Instruction:',
                        widget.folder['instruction_content'] ??
                            'No instruction'),
                    _buildPDFTableRow(
                        'Coach Detail:',
                        widget.folder['coach_detail_content'] ??
                            'No coach detail'),
                    _buildPDFTableRow(
                        'Remarks:',
                        [
                          widget.folder['activities_details_remarks'] ??
                              'No remarks',
                          widget.folder['coach_detail_renarks'] ?? 'No remarks',
                          widget.folder['outputs_remarks'] ?? 'No remarks',
                          widget.folder['project_cards_remarks'] ??
                              'No remarks',
                          widget.folder['instruction_remarks'] ?? 'No remarks',
                        ].join('\n')), // New row for remarks
                  ],
                ),
              ],
            );
          },
        ),
      );

      if (kIsWeb) {
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'folder_details.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
      // Removed the Snackbar display
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('PDF generated successfully')),
      // );
    } catch (e) {
      print('Error generating PDF: $e');
      // Removed the Snackbar display
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to generate PDF: $e')),
      // );
    }
  }

  pw.TableRow _buildPDFTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  Future<void> _generateExcel(BuildContext context) async {
    // Create a new Excel document
    final Excel excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Add headers and folder details
    sheet.appendRow(
        ['Project Code', widget.folder['project_subject_code'] ?? 'No code']);
    sheet.appendRow([
      'Project Description',
      widget.folder['project_subject_description'] ?? 'No description'
    ]);
    sheet.appendRow(
        ['Start Date', widget.folder['project_start_date'] ?? 'No start date']);
    sheet.appendRow(
        ['End Date', widget.folder['project_end_date'] ?? 'No end date']);
    sheet.appendRow(
        ['Module', widget.folder['module_master_name'] ?? 'Unknown']);
    sheet.appendRow([
      'Activity',
      widget.folder['activities_details_content'] ?? 'No activity'
    ]);
    sheet.appendRow(['Card', widget.folder['cards_title'] ?? 'No card']);
    sheet
        .appendRow(['Output', widget.folder['outputs_content'] ?? 'No output']);
    sheet.appendRow([
      'Instruction',
      widget.folder['instruction_content'] ?? 'No instruction'
    ]);
    sheet.appendRow([
      'Coach Detail',
      widget.folder['coach_detail_content'] ?? 'No coach detail'
    ]);

    // New: Add remarks to the Excel sheet
    sheet.appendRow([
      'Remarks',
      [
        widget.folder['activities_details_remarks'] ?? 'No remarks',
        widget.folder['coach_detail_renarks'] ?? 'No remarks',
        widget.folder['outputs_remarks'] ?? 'No remarks',
        widget.folder['project_cards_remarks'] ?? 'No remarks',
        widget.folder['instruction_remarks'] ?? 'No remarks',
      ].join('\n') // Join remarks with a newline
    ]);
    // Add headers for Excel table
    final headers = ['Field', 'Details'];

    // Add header row
    sheet.appendRow(headers);

    // Add the folder details in a similar structure to the PDF
    final folderDetails = [
      ['Project Title:', widget.folder['project_title'] ?? 'Unnamed Folder'],
      ['Project Code:', widget.folder['project_subject_code'] ?? 'No code'],
      [
        'Project Description:',
        widget.folder['project_subject_description'] ?? 'No description'
      ],
      ['Start Date:', widget.folder['project_start_date'] ?? 'No start date'],
      ['End Date:', widget.folder['project_end_date'] ?? 'No end date'],
      ['Module:', widget.folder['module_master_name'] ?? 'Unknown'],
      [
        'Activity:',
        widget.folder['activities_details_content'] ?? 'No activity'
      ],
      ['Card:', widget.folder['cards_title'] ?? 'No card'],
      ['Output:', widget.folder['outputs_content'] ?? 'No output'],
      [
        'Instruction:',
        widget.folder['instruction_content'] ?? 'No instruction'
      ],
      [
        'Coach Detail:',
        widget.folder['coach_detail_content'] ?? 'No coach detail'
      ],
    ];

    // Append each row with folder details to the Excel sheet
    for (var row in folderDetails) {
      sheet.appendRow(row);
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _addLesson(context),
      //   tooltip: 'Add Lesson',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
