import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ManageUsersPage(),
    );
  }
}

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  List<User> _users = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse('http://regestrationrenion.atwebpages.com/api.php'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData is List) {
        setState(() {
          _users = jsonData.map((userJson) => User.fromJson(userJson)).toList();
          _isLoading = false;
        });
      } else {
        print('Unexpected response format: $jsonData');
      }
    } else {
      print('HTTP error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildUserForm(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UsersListPage(users: _users)),
          );
        },
        child: const Icon(Icons.people),
      ),
    );
  }

  Widget _buildUserForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create New User',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _prenameController,
          decoration: const InputDecoration(
            labelText: 'Prename',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _addUser,
          child: const Text('Add User'),
        ),
      ],
    );
  }

  Future<void> _addUser() async {
    final String name = _nameController.text;
    final String prename = _prenameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (name.isNotEmpty &&
        prename.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://regestrationrenion.atwebpages.com/api.php'),
        body: {
          'name': name,
          'prename': prename,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        _nameController.clear();
        _prenameController.clear();
        _emailController.clear();
        _passwordController.clear();
        setState(() {
          _users.add(User(
            id: jsonDecode(response.body)['id'],
            name: name,
            prename: prename,
            email: email,
            password: password,
          ));
        });
        _showSnackBar('User added successfully');
      } else {
        _showSnackBar('Failed to add user');
      }
    } else {
      _showSnackBar('All fields are required');
    }
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(message)));
  }
}

class User {
  final int id;
  late final String name;
  late final String prename;
  late final String email;
  late final String password;

  User({
    required this.id,
    required this.name,
    required this.prename,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      name: json['name'] as String,
      prename: json['prename'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }
}

class UsersListPage extends StatelessWidget {
  final List<User> users;

  const UsersListPage({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Existing Users',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[200]!),
                    dataRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[50]!),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Prename')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Password')),
                    ],
                    rows: users.map((user) {
                      return DataRow(cells: [
                        DataCell(Text(user.id.toString())),
                        DataCell(Text(user.name)),
                        DataCell(Text(user.prename)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.password)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
