import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateVotePage extends StatefulWidget {
  const CreateVotePage({super.key});

  @override
  _CreateVotePageState createState() => _CreateVotePageState();
}

class _CreateVotePageState extends State<CreateVotePage> {
  
  final List<String> _selectedParticipants = [];
  DateTime _closingDate = DateTime.now();
  List<Map<String, dynamic>>? _participantsList;
  final List<Map<String, dynamic>> _optionsWithKeys = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _newOptionController = TextEditingController();

  Future<DateTime?> _selectDateTime(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        return DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
            selectedTime.hour, selectedTime.minute);
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchParticipants() async {
    final response = await http
        .get(Uri.parse('http://regestrationrenion.atwebpages.com/api.php'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      // Handle error
      return [];
    }
  }

  void _saveVote(BuildContext context) async {
  // Check if any of the required fields are null
  if (_titleController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _optionsWithKeys.isEmpty ||
      _selectedParticipants.isEmpty ||
      _closingDate == null) {
    _showSnackBar("All fields are required", context);
    return;
  }

  Map<String, dynamic> voteData = {
    'title': _titleController.text,
    'description': _descriptionController.text,
    'options': _optionsWithKeys.map((option) => {'value': option['value']}).toList(),
    'participants': _selectedParticipants,
    'closing_date': _closingDate.toIso8601String(),
  };

  try {
    final response = await http.post(
      Uri.parse('http://regestrationrenion.atwebpages.com/vots.php'),
      body: jsonEncode(voteData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Vote saved successfully
      _showSnackBar("Vote saved successfully", context);
    } else {
      // Failed to save vote
      _showSnackBar("Failed to save vote", context);
    }
  } catch (e) {
    // Exception occurred
    _showSnackBar("An error occurred", context);
  }
}


void _showSnackBar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ),
  );
}



Widget _buildRemainingTime(String? closingDateString) {
  // Check if closingDateString is null
  if (closingDateString == null) {
    return const Text(
      'Closing date not available',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.red, // Display in red to indicate an issue
      ),
    );
  }

  // Parse the closing date string to DateTime object
  DateTime closingDate = DateTime.parse(closingDateString);

  // Calculate the remaining time
  Duration remainingTime = closingDate.difference(DateTime.now());

  // Format the remaining time
  String remainingTimeString = '';
  if (remainingTime.inDays > 0) {
    remainingTimeString += '${remainingTime.inDays} days ';
  }
  remainingTimeString += '${remainingTime.inHours.remainder(24)} hours ${remainingTime.inMinutes.remainder(60)} minutes';

  // Return a Text widget displaying the remaining time
  return Text(
    'Remaining Time: $remainingTimeString',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Vote'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter vote title',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter vote description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Options',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _optionsWithKeys.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: TextFormField(
                            initialValue: _optionsWithKeys[index]['value'],
                            onChanged: (newValue) {
                              setState(() {
                                _optionsWithKeys[index]['value'] = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Option ${index + 1}',
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _optionsWithKeys.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newOptionController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'New Option',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              _optionsWithKeys.add({
                                'key':
                                    'option_${DateTime.now().millisecondsSinceEpoch}_${_optionsWithKeys.length}',
                                'value': _newOptionController.text,
                                'voteCount': 0,
                              });
                              _newOptionController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchParticipants(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Participants',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Select participants'),
          value: _selectedParticipants.isNotEmpty
              ? _selectedParticipants.first
              : null,
          onChanged: (String? newValue) {
            setState(() {
              if (newValue != null) {
                if (_selectedParticipants.contains(newValue)) {
                  _selectedParticipants.remove(newValue);
                } else {
                  _selectedParticipants.add(newValue);
                }
              }
            });
          },
          items: snapshot.data!.map<DropdownMenuItem<String>>((participant) {
            return DropdownMenuItem<String>(
              value: '${participant['id']}',
              child: Text('${participant['name']} ${participant['prename']}'),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Selected Participants:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _selectedParticipants.map<Widget>((selectedId) {
            final selectedParticipant = snapshot.data!.firstWhere(
              (participant) => participant['id'] == selectedId,
              orElse: () => {'name': 'Unknown', 'prename': 'Participant'},
            );
            return Chip(
              label: Text(
                '${selectedParticipant['name']} ${selectedParticipant['prename']}',
              ),
              onDeleted: () {
                setState(() {
                  _selectedParticipants.remove(selectedId);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
                        } else {
                          return const Text('No participants found');
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                   ElevatedButton(
  onPressed: () {
    _saveVote(context); // Call function to save vote with context
  },
  child: const Text('Save Vote'),
),

                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vote Closing Date:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('dd/MM/yyyy hh:mm a').format(_closingDate),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final selectedDateTime =
                                  await _selectDateTime(context);
                              if (selectedDateTime != null) {
                                setState(() {
                                  _closingDate = selectedDateTime;
                                });
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Change'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(),
Expanded(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Announcement of Voting Results',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchOptionVotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                // Group options by vote_id
                Map<int, List<Map<String, dynamic>>> groupedOptions = {};
                snapshot.data!.forEach((option) {
                  int? voteId;
                  if (option['vote_id'] is int) {
                    voteId = option['vote_id'];
                  } else if (option['vote_id'] is String) {
                    voteId = int.tryParse(option['vote_id']);
                  }

                  if (!groupedOptions.containsKey(voteId)) {
                    groupedOptions[voteId!] = [];
                  }
                  groupedOptions[voteId]!.add(option);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: groupedOptions.entries.map<Widget>((entry) {
                    int voteId = entry.key;
                    String title = entry.value[0]['title'] ?? '';
                    String description = entry.value[0]['description'] ?? '';
                    int totalVotes = entry.value.fold(
                      0,
                      (total, option) =>
                          total +
                          (int.parse(option['vote_count'].toString()) ?? 0),
                    );

                    // Calculate remaining time
                    DateTime closingDate = DateTime.parse(entry.value[0]['closing_date']);
                    Duration remainingTime = closingDate.difference(DateTime.now());

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Title: $title',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Description: $description',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Options and Votes',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: entry.value.map<Widget>((option) {
                              String optionValue = option['option_value'] ?? '';
                              int voteCount =
                                  int.tryParse(option['vote_count'].toString()) ?? 0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      optionValue.isNotEmpty
                                          ? optionValue
                                          : 'Unknown Option',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    Text(
                                      'Votes: $voteCount',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _viewVotingParticipants(optionValue);
                                      },
                                      child: const Text('View Participants'),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Total Votes for All Options: $totalVotes',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Remaining Time: ${remainingTime.inDays} days ${remainingTime.inHours.remainder(24)} hours',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              } else {
                return Center(
                  child: Column(
                    children: [
                      const Text(
                        'No votes set yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.sentiment_dissatisfied,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check back later for updates!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  ),
),


        ],
      ),
    );
  }

 Future<List<Map<String, dynamic>>> _fetchOptionVotes() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int userId = prefs.getInt('participant_id') ?? 0; // Retrieve user ID from shared preferences
  print("User ID: $userId");

  final response = await http.get(
    Uri.parse('http://regestrationrenion.atwebpages.com/option_votes.php'),
  );

  if (response.statusCode == 200) {
    List<Map<String, dynamic>> optionVotes =
        List<Map<String, dynamic>>.from(jsonDecode(response.body));

    // Print the fetched data
    print("Fetched data: $optionVotes");

    return optionVotes;
  } else {
    // Handle error
    print("Error: Failed to fetch option votes. Status code: ${response.statusCode}");
    return [];
  }
}


  void _viewVotingParticipants(String optionValue) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://regestrationrenion.atwebpages.com/show_participants.php'),
        body: {'option_value': optionValue},
      );

      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> participants =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        // Display names and prenames of participants who voted for this option
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Participants who voted for Option $optionValue'),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(
                    maxHeight: 400), // Adjust the maximum height as needed
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total Participants: ${participants.length}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // Ensure the ListView does not scroll
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          final participant = participants[index];
                          return ListTile(
                            title: Text(
                                '${participant['participant_name']} ${participant['participant_prename']}'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle error
        print('Failed to fetch participants');
      }
    } catch (e) {
      // Exception occurred
      print('Exception: $e');
    }
  }
}
