import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  _MeetingsScreenState createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  List<Map<String, dynamic>> _meetings = [];
  List<Map<String, dynamic>> _preparationMeetings = [];
  String? _selectedMeetingType;
  late DateTime _selectedDate;
  List<Map<String, dynamic>> _enCoursMeetings = [];
  List<Map<String, dynamic>> _termineesMeetings = [];

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
    _fetchPreparationMeetings();
    _selectedDate = DateTime.now();
  }

  Future<void> _fetchMeetings() async {
    final response = await http.get(Uri.parse('http://regestrationrenion.atwebpages.com/get_meetings.php'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> allMeetings = jsonDecode(response.body).cast<Map<String, dynamic>>();
      final DateTime currentDate = DateTime.now();

      setState(() {
        _meetings = allMeetings;
        _enCoursMeetings = [];
        _preparationMeetings = [];
        _termineesMeetings = [];

        for (var meeting in allMeetings) {
          final DateTime meetingDate = DateTime.parse(meeting['date']);

          if (meetingDate.isAfter(currentDate)) {
            _preparationMeetings.add(meeting);
          } else if (meetingDate.year == currentDate.year &&
              meetingDate.month == currentDate.month &&
              meetingDate.day == currentDate.day) {
            _enCoursMeetings.add(meeting);
          } else {
            _termineesMeetings.add(meeting);
          }
        }
      });
    } else {
      throw Exception('Failed to fetch meetings');
    }
  }

  Future<void> _fetchPreparationMeetings() async {
    final response = await http.get(Uri.parse('http://regestrationrenion.atwebpages.com/get_preparation_meetings.php'));

    if (response.statusCode == 200) {
      setState(() {
        _preparationMeetings = jsonDecode(response.body).cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to fetch preparation meetings');
    }
  }

  Future<void> _addPreparationMeeting(String title, String date) async {
    final response = await http.post(
      Uri.parse('http://regestrationrenion.atwebpages.com/add_meeting.php'),
      body: {
        'title': title,
        'date': date,
      },
    );

    if (response.statusCode == 200) {
      _fetchPreparationMeetings();
    } else {
      throw Exception('Failed to add preparation meeting');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMeetingCategory(
                'Programmée',
                _meetings.map<Widget>((meeting) => _buildMeetingCard(meeting)).toList(),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildMeetingCategory(
                'En Préparation',
                [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                title: const Text('Ajouter une réunion de préparation'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value: _selectedMeetingType,
                                      items: const [
                                        DropdownMenuItem(value: 'Conseil d’administration', child: Text('Conseil d’administration')),
                                        DropdownMenuItem(value: 'Assemblée générale ordinaire', child: Text('Assemblée générale ordinaire')),
                                        DropdownMenuItem(value: 'Assemblée générale extraordinaire', child: Text('Assemblée générale extraordinaire')),
                                        DropdownMenuItem(value: 'Assemblée générale mixte', child: Text('Assemblée générale mixte')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedMeetingType = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Sélectionner un type',
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    InkWell(
                                      onTap: () async {
                                        final DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (picked != null && picked != _selectedDate) {
                                          setState(() {
                                            _selectedDate = picked;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _addPreparationMeeting(_selectedMeetingType!, '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}');
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Enregistrer'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Annuler'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10), ..._preparationMeetings.map<Widget>((meeting) => _buildMeetingCard(meeting)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildMeetingCategory(
                'En Cours',
                _enCoursMeetings.map<Widget>((meeting) => _buildMeetingCard(meeting)).toList(),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildMeetingCategory(
                'Terminées',
                _termineesMeetings.map<Widget>((meeting) => _buildMeetingCard(meeting)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingCategory(String title, List<Widget> meetings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getCategoryColor(title)),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemCount: meetings.length,
            itemBuilder: (BuildContext context, int index) {
              return meetings[index];
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Programmée':
        return Colors.blue;
      case 'En Préparation':
        return Colors.green;
      case 'En Cours':
        return Colors.orange;
      case 'Terminées':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(
          meeting['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meeting['date']),
            Text(
              'Time: ${meeting['time']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Location: ${meeting['location']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
