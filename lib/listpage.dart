import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flip_card/flip_card.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:html' as html;
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hexcolor/hexcolor.dart';

import 'config.dart';

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
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/masterlist.php'),
        body: {
          'operation': 'getFolder',
        },
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
                    })
                .toList());
          });
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
        print('Failed to load folders. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to load folders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching folders: $e');
      // You might want to show an error message to the user here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching folders: $e')),
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

  Future<void> _addFolder(String folderName, String creationTime) async {
    Map<String, dynamic> data = {
      'folder_name': folderName,
      'folder_date': creationTime,
    };
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}add.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'operation': 'addfolder',
          'json': jsonEncode(data),
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Folder created successfully with ID: ${responseData['id']}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Folder created successfully')),
          );
          await _fetchFolders(); // Refresh the folder list
        } else {
          print('Failed to create folder: ${responseData['error']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to create folder: ${responseData['error']}')),
          );
        }
      } else {
        print('Failed to create folder: Server error ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error occurred')),
        );
      }
    } catch (e) {
      print('Error adding folder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _onFolderTap(Map<String, dynamic> folder) {
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
        html.window.open(url, '_blank');
        html.Url.revokeObjectUrl(url);
      } else {
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/my_folders.pdf');
        await file.writeAsBytes(await pdf.save());
        OpenFile.open(file.path);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
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
  Map<String, dynamic>? cardData;

  @override
  void initState() {
    super.initState();
    _fetchCardData();
  }

  Future<void> _fetchCardData() async {
    final projectId = widget.folder['projectId'];
    final backCardsHeaderFrontId = widget.folder['back_cards_header_frontId'];

    print(
        'Fetching card data for projectId: $projectId, backCardsHeaderFrontId: $backCardsHeaderFrontId');

    try {
      // Make the HTTP POST request to your API
      final response = await http.post(
        Uri.parse('http://localhost/design/lib/api/masterlist.php'),
        body: {
          'operation': 'getCards1',
          'projectId': projectId.toString(),
          'cardId': backCardsHeaderFrontId.toString(),
        },
      );

      // Check if the response status is OK (HTTP 200)
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        // Check if the response is a map (expected JSON format)
        if (data is Map<String, dynamic>) {
          if (data['success'] == true && data['data'] != null) {
            setState(() {
              cardData = data['data'];
            });
            print('Fetched Card Data:');
            data['data'].forEach((key, value) {
              print('$key: $value');
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF5E6D3)
              .withOpacity(0.9), // Pale sand color with opacity
          title: Text(
            widget.folder['project_title'] ?? 'Unnamed Folder',
            style: TextStyle(color: Colors.black87),
          ),
          content: SingleChildScrollView(
            child: Table(
              border: TableBorder.all(color: Colors.black87),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('Project Code',
                    widget.folder['project_subject_code'] ?? 'No code'),
                _buildTableRow(
                    'Project Description',
                    widget.folder['project_subject_description'] ??
                        'No description'),
                _buildTableRow('Start Date',
                    widget.folder['project_start_date'] ?? 'No start date'),
                _buildTableRow('End Date',
                    widget.folder['project_end_date'] ?? 'No end date'),
                _buildTableRow(
                    'Module', widget.folder['module_master_name'] ?? 'Unknown'),
                _buildTableRow(
                    'Activity',
                    widget.folder['activities_details_content'] ??
                        'No activity'),
                _buildTableRow(
                    'Card', widget.folder['cards_title'] ?? 'No card'),
                _buildTableRow(
                    'Output', widget.folder['outputs_content'] ?? 'No output'),
                _buildTableRow('Instruction',
                    widget.folder['instruction_content'] ?? 'No instruction'),
                _buildTableRow('Coach Detail',
                    widget.folder['coach_detail_content'] ?? 'No coach detail'),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _generateExcel(context),
                  child: const Text('Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE6D0B3),
                    foregroundColor: Colors.black87,
                    minimumSize: Size(90, 40),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _generatePDF(context),
                  child: const Text('PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE6D0B3),
                    foregroundColor: Colors.black87,
                    minimumSize: Size(90, 40),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  TableRow _buildTableRow(String label, String value) {
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
      ],
    );
  }

  Future<void> _generatePDF(BuildContext context) async {
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
                      'What Activities will my students do?:',
                      widget.folder['activities_details_content'] ??
                          'No activity'),
                  _buildPDFTableRow(
                      'What are the (2) cards will my student use?:',
                      widget.folder['cards_title'] ?? 'No card'),
                  _buildPDFTableRow('What are the expected Outputs?:',
                      widget.folder['outputs_content'] ?? 'No output'),
                  _buildPDFTableRow(
                      'What instructions will i give my students?:',
                      widget.folder['instruction_content'] ?? 'No instruction'),
                  _buildPDFTableRow(
                      'How can I coach my students while doing this activity?:',
                      widget.folder['coach_detail_content'] ??
                          'No coach detail'),
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
        html.window.open(url, '_blank');
        html.Url.revokeObjectUrl(url);
      } else {
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/folder_details.pdf');
        await file.writeAsBytes(await pdf.save());
        OpenFile.open(file.path);
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
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    // Add generation date and time
    sheet.appendRow([
      TextCellValue('Generated on:'),
      TextCellValue(formattedDate),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('')
    ]); // Empty row for spacing

    // Add folder details
    sheet.appendRow([
      TextCellValue('Project Code'),
      TextCellValue(widget.folder['project_subject_code'] ?? 'No code'),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue('Project Description'),
      TextCellValue(
          widget.folder['project_subject_description'] ?? 'No description'),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue('Start Date'),
      TextCellValue(widget.folder['project_start_date'] ?? 'No start date'),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue('End Date'),
      TextCellValue(widget.folder['project_end_date'] ?? 'No end date'),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue(widget.folder['module_master_name'] ?? 'Unknown'),
      TextCellValue(''),
      TextCellValue('NOTES/REMARKS')
    ]);
    sheet.appendRow([
      TextCellValue('What activities will my students do?'),
      TextCellValue(
          widget.folder['activities_details_content'] ?? 'No activity'),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue('What are the (2) cards will my  student use?'),
      TextCellValue(widget.folder['cards_title'] ?? 'No card'),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue('What are the expected outputs?'),
      TextCellValue(widget.folder['outputs_content'] ?? 'No output'),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue('What instructions will I give my students?'),
      TextCellValue(widget.folder['instruction_content'] ?? 'No instruction'),
      TextCellValue('')
    ]);
    sheet.appendRow([
      TextCellValue('How can I coach my students while doing this activity?'),
      TextCellValue(widget.folder['coach_detail_content'] ?? 'No coach detail'),
      TextCellValue('')
    ]);

    // Set column widths
    sheet.setColumnWidth(0, 50);
    sheet.setColumnWidth(1, 50);
    sheet.setColumnWidth(2, 50);

    final directory =
        Directory('/storage/emulated/0/Download'); // Change to Downloads folder
    final filePath = '${directory.path}/folder_details.xlsx';
    final file = File(filePath);
    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      file
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel file saved to $filePath')),
    );
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
      body: Center(
        child: cardData == null
            ? CircularProgressIndicator()
            : FlipCard(
                direction: FlipDirection.HORIZONTAL,
                speed: 1000,
                onFlipDone: (status) {
                  print(status);
                },
                front: Container(
                  width: 300,
                  height: 600,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cardData?['cards_title'] ?? 'No title',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        cardData?['cards_content'] ?? 'No content',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                back: Container(
                  width: 300,
                  height: 600,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.purple, Colors.blue],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cardData?['back_content'] ?? 'No content',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addLesson(context),
        tooltip: 'Add Lesson',
        child: const Icon(Icons.add),
      ),
    );
  }
}
