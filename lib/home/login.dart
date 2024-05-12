import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sgovs_desktop/home/sign_up.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscureText = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }

  Future<void> login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    var url = Uri.parse('http://regestrationrenion.atwebpages.com/login_admin.php');

    try {
      var response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to login. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 800,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/4.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Builder(
            builder: (context) => Form(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(top: 120),
                      child: Image.asset("assets/images/l1.png"),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      child: const Center(
                        child: Text(
                          ' Bienvenue    ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(28, 120, 117, 1),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: const Color.fromRGBO(250, 166, 66, 0.6),
                      ),
                      margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'email',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Sora',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.mail, color: Colors.white),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 20.0,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: const Color.fromRGBO(250, 166, 66, 0.6),
                      ),
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: obscureText,
                        decoration: InputDecoration(
                          hintText: 'mot de passe',
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Sora',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 20.0,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(28, 120, 117, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: 50,
                      width: 180,
                      child: TextButton(
                        onPressed: () {
                          login(context);
                        },
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0), // Add some space
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUp()), // Navigate to sign-up page
                        );
                      },
                      child: const Text(
                        'Vous n\'avez pas de compte ? Créez-en un ici',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
