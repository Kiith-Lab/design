import 'dart:math';

import 'package:design/test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart';

void main() {
  runApp(const MaterialApp(home: Prototype()));
}

class Prototype extends StatefulWidget {
  const Prototype({super.key});

  @override
  _PrototypeState createState() => _PrototypeState();
}

class _PrototypeState extends State<Prototype> {
  List<dynamic> frontCards = [];
  List<dynamic> backCards = [];
  bool isLoading = true;
  String error = '';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List fetchedFrontCards = await getData3();
      List fetchedBackCards = await getBacker3();
      setState(() {
        frontCards = fetchedFrontCards;
        backCards = fetchedBackCards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/Design_Thinking_Prototype_Page.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 75),
                const Text(
                  "Prototype",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error.isNotEmpty
                  ? Center(child: Text(error))
                  : frontCards.isEmpty
                      ? const Center(child: Text('No data available'))
                      : Column(
                          children: [
                            const SizedBox(
                                height: 60), // Add space for the back button
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        searchQuery = '';
                                        _searchController.clear();
                                        _searchFocusNode.unfocus();
                                      });
                                    },
                                  ),
                                  prefixIcon: const Icon(Icons.search),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 45), // Added SizedBox here

                            Expanded(
                              child: ListView.builder(
                                itemCount: frontCards.length,
                                itemBuilder: (context, index) {
                                  if (searchQuery.isNotEmpty) {
                                    if (!RegExp(searchQuery,
                                            caseSensitive: false)
                                        .hasMatch(
                                            frontCards[index]['cards_title'])) {
                                      return Container();
                                    }
                                  }
                                  return Card(
                                    elevation: 4,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      title: Text(
                                        frontCards[index]['cards_title'] ??
                                            'No title',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FlashcardPage(
                                                  frontTitle: frontCards[index]
                                                          ['cards_title'] ??
                                                      'No title',
                                                  backtitle: frontCards[index][
                                                          'back_cards_header_title'] ??
                                                      'No title',
                                                  frontContent: frontCards[
                                                              index]
                                                          ['cards_content'] ??
                                                      'No title',
                                                  frontImage: frontCards[index]
                                                          ['cards_image'] ??
                                                      'No content',
                                                  cardId: frontCards[index]
                                                      ['cards_id'])),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
        ],
      ),
    );
  }

  Future<List> getData3() async {
    String url = "${baseUrl}view.php";
    Map<String, String> requestBody = {
      'operation': 'getPrototype',
    };
    try {
      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String trimmedBody = response.body.trim();
        var decodedData = jsonDecode(trimmedBody);
        if (decodedData is List) {
          return decodedData;
        } else if (decodedData is Map && decodedData.containsKey('error')) {
          throw Exception(decodedData['error']);
        } else {
          throw Exception('Invalid data format received');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Failed to parse JSON: ${e.message}');
      } else if (e is http.ClientException) {
        throw Exception(
            'Failed to connect to the server. Please check your network connection and try again.');
      } else {
        throw Exception('Failed to load data: $e');
      }
    }
  }

  Future<List> getBacker3() async {
    String url = "${baseUrl}view.php";
    Map<String, String> requestBody = {
      'operation': 'getBack3',
    };
    try {
      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        String trimmedBody = response.body.trim();
        var decodedData = jsonDecode(trimmedBody);
        if (decodedData is List) {
          return decodedData;
        } else if (decodedData is Map && decodedData.containsKey('error')) {
          throw Exception(decodedData['error']);
        } else {
          throw Exception('Invalid data format received');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Failed to parse JSON: ${e.message}');
      } else if (e is http.ClientException) {
        throw Exception(
            'Failed to connect to the server. Please check your network connection and try again.');
      } else {
        throw Exception('Failed to load data: $e');
      }
    }
  }
}

class FlashcardPage extends StatefulWidget {
  final String frontTitle;
  final String frontContent;
  final String frontImage;
  final String backtitle;
  final int cardId;

  const FlashcardPage({
    super.key,
    required this.frontTitle,
    required this.frontContent,
    required this.frontImage,
    required this.backtitle,
    required this.cardId,
  });

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  List<dynamic> backCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    fetchBackCards();
  }

  Future<void> fetchBackCards() async {
    try {
      String url = "${baseUrl}view.php";
      Map<String, String> requestBody = {
        'operation': 'getBack3',
        'cardId': widget.cardId.toString(), // Ensure cardId is being passed
      };

      // Print the cardId and request body for debugging
      print('Fetching back contents for cardId: ${widget.cardId}');
      print('Request body: $requestBody');

      http.Response response = await http
          .post(
            Uri.parse(url),
            body: requestBody,
          )
          .timeout(const Duration(seconds: 10));

      // Debug response status and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        String trimmedBody = response.body.trim();
        var decodedData = jsonDecode(trimmedBody);

        // Debugging: check if data was decoded properly
        print('Decoded data: $decodedData');

        if (decodedData is List && decodedData.isNotEmpty) {
          setState(() {
            backCards = decodedData;
            isLoading = false;
          });
        } else {
          print('No data or invalid format received');
          setState(() {
            backCards = [];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching back cards: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add More'),
          content: const Text('Do you want to add more lessons?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Test()),
                );
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Prototype()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade200, Colors.red.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: List.generate(50, (index) {
                final random = Random();
                final size = random.nextInt(60) + 20.0;
                final left =
                    random.nextDouble() * MediaQuery.of(context).size.width;
                final top =
                    random.nextDouble() * MediaQuery.of(context).size.height;
                final duration = random.nextInt(5) + 3;

                return Positioned(
                  left: left,
                  top: top,
                  child: AnimatedContainer(
                    duration: Duration(seconds: duration),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.red.shade200, Colors.red.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.add_box_outlined, color: Colors.white),
              onPressed: _showAddDialog,
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        final angle = _animation.value * 3.1415926535897932;
                        return Transform(
                          transform: Matrix4.rotationY(angle),
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: 0.8, // Lower the opacity of the flip card
                            child: _isFront
                                ? _buildCard(isFront: true)
                                : Transform(
                                    transform:
                                        Matrix4.rotationY(3.1415926535897932),
                                    alignment: Alignment.center,
                                    child: _buildCard(isFront: false),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCard({required bool isFront}) {
    return Container(
      width: 400,
      height: 800,
      margin: const EdgeInsets.only(top: 50),
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.3),
                      Colors.purple.withOpacity(0.1),
                      Colors.purple.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isFront
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.frontTitle,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        widget.frontImage.isNotEmpty
                            ? Image.asset(
                                'assets/images/DT/${widget.frontImage}',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              widget.frontContent,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: backCards.map((backCard) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(backCard['back_cards_header_title'] ??
                                  'No title'),
                              Text(
                                backCard['back_content_title'] ?? 'No title',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                backCard['back_content'] ?? 'No content',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddLessonPage extends StatelessWidget {
  const AddLessonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const Center(
        child: Text('lesson list here'),
      ),
    );
  }
}
