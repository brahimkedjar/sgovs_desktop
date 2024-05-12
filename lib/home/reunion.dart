import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Reunion extends StatefulWidget {
  const Reunion({super.key});

  @override
  State<Reunion> createState() => _ReunionState();
}

class _ReunionState extends State<Reunion> with SingleTickerProviderStateMixin {
  String MeetName = "CA24/11/24";
 List<Map<String, dynamic>> _meetings = [];
  List<Map<String, dynamic>> _preparationMeetings = [];
  String? _selectedMeetingType;
  late DateTime _selectedDate;
List<Map<String, dynamic>>? _enCoursMeetings = [];
  List<Map<String, dynamic>> _termineesMeetings = [];

  int _selectedIndex = 0;
  PageController _pageController = PageController();
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _fetchMeetings();
    _selectedIndex = 0;
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
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
            _enCoursMeetings?.add(meeting);
          } else {
            _termineesMeetings.add(meeting);
          }
        }
      });
    } else {
      throw Exception('Failed to fetch meetings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    const Text(
                      "Réunions Programmées",
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 120, 117, 1),
                      
                      ),
                      
                    ),
                    Container(
                      height: 300,
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 0.0,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 60,
                        right: 60,
                        top: 0,
                        bottom: 10.0,
                      ),
                      child: Image.asset(
                        'assets/images/v.png',
                      ),
                    ),
                    Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(28, 120, 117, 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          top: 0,
                          bottom: 10.0,
                        ),
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 10,
                        ),
                        child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                      itemCount: _meetings.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 4,
                          child: ListTile(
  title: Text(
    _meetings[index]['title'],
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Text(
    "${_meetings[index]['date']} a ${_meetings[index]['time']}",
  ),
  // Additional line for displaying location
  trailing: Text(_meetings[index]['location']),
),
                        );
                      },
                    ),)
                  ],
                )),
            Container(decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    const Text(
                      "Réunions En cours ...",
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 120, 117, 1),
                      ),
                      
                    ),
                    Container(
                      height: 300,
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 0.0,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 60,
                        right: 60,
                        top: 0,
                        bottom: 10.0,
                      ),
                      child: Image.asset(
                        'assets/images/1.png',
                      ),
                    ),
                    Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(28, 120, 117, 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          top: 0,
                          bottom: 10.0,
                        ),
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 10,
                        ),
                        
                    child: ListView.separated(
  separatorBuilder: (BuildContext context, int index) => const Divider(),
  itemCount: _enCoursMeetings?.length ?? 0, // Use null-aware operator to handle null _enCoursMeetings
  itemBuilder: (BuildContext context, int index) {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text(
          _enCoursMeetings?[index]['title'] ?? '', // Use null-aware operator to handle null _enCoursMeetings and null title
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_enCoursMeetings?[index]['date'] ?? ''), // Use null-aware operator to handle null _enCoursMeetings and null date
      ),
    );
  },
),

                  ),
                  ],
                )),
            Container( decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    const Text(
                      "Réunions Terminées",
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 120, 117, 1),
                      
                      ),
                      
                    ),
                    Container(
                      height: 300,
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 0.0,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 60,
                        right: 60,
                        top: 0,
                        bottom: 10.0,
                      ),
                      child: Image.asset(
                        'assets/images/c.png',
                      ),
                    ),
                    Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(28, 120, 117, 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        margin: const EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          top: 0,
                          bottom: 10.0,
                        ),
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 10,
                        ),
                        child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                      itemCount: _termineesMeetings.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              _termineesMeetings[index]['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(_termineesMeetings[index]['date']),
                          ),
                        );
                      },
                    ),)
                  ],
                )),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color : Color.fromRGBO(28, 120, 117, 1),
            //color: Colors.blue,
            
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text(
                  "programmées",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
              TextButton(
                child: const Text(
                  "en cours",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
              TextButton(
                child: const Text(
                  "terminées",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
