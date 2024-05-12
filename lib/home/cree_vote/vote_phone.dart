import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Participant Votes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ParticipantVotesPage(),
    );
  }
}

class ParticipantVotesPage extends StatefulWidget {
  const ParticipantVotesPage({super.key});

  @override
  _ParticipantVotesPageState createState() => _ParticipantVotesPageState();
}

class _ParticipantVotesPageState extends State<ParticipantVotesPage> {
  List<Map<String, dynamic>> _votes = [];

  @override
  void initState() {
    super.initState();
    _fetchVotes();
  }

  Future<void> _fetchVotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('participant_id') ?? 0; // Retrieve user ID from shared preferences

    final response = await http.post(
      Uri.parse('http://regestrationrenion.atwebpages.com/participant_votes.php'),
      body: {'user_id': userId.toString()},
    );

    if (response.statusCode == 200) {
      setState(() {
        _votes = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      print('Failed to fetch votes: ${response.statusCode}');
    }
  }

  Future<void> _submitVote(String voteId, String optionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('participant_id') ?? ""; // Retrieve user ID from shared preferences

    final response = await http.post(
      Uri.parse('http://regestrationrenion.atwebpages.com/submit_vote.php'),
      body: {
        'user_id': userId,
        'vote_id': voteId,
        'option_id': optionId,
      },
    );

    if (response.statusCode == 200) {
      await _fetchVotes();
    } else {
      print('Failed to submit vote: ${response.statusCode}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participant Votes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _votes.length,
                itemBuilder: (context, index) {
                  final vote = _votes[index];
                  final List<dynamic> options = vote['options'];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Title: ${vote['title']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text('Description: ${vote['description']}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Closing Date: ${vote['closing_date']}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 16),
                          const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: options.map<Widget>((option) {
                              if (option is String) {
                                return Row(
                                  children: [
                                    Radio(
                                      value: option,
                                      groupValue: vote['selected_option'],
                                      onChanged: (value) {
                                        setState(() {
                                          vote['selected_option'] = value;
                                        });
                                      },
                                    ),
                                    Text(option, style: const TextStyle(fontSize: 16)),
                                  ],
                                );
                              } else if (option is Map) {
                                final optionValue = option['value'];
                                return Row(
                                  children: [
                                    Radio(
                                      value: optionValue,
                                      groupValue: vote['selected_option'],
                                      onChanged: (value) {
                                        setState(() {
                                          vote['selected_option'] = value;
                                        });
                                      },
                                    ),
                                    Text(optionValue, style: const TextStyle(fontSize: 16)),
                                  ],
                                );
                              }
                              return Container();
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (vote['selected_option'] != null) {
                                _submitVote(vote['id'], vote['selected_option']);
                              } else {
                                print('Please select an option');
                              }
                            },
                            child: const Text('Vote', style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
