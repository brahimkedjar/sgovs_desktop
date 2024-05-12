import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sgovs_desktop/home/login.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final nameController = TextEditingController();
  final prenameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscureText = true;

  Future<void> signUp(BuildContext context) async {
    String name = nameController.text.trim();
    String prename = prenameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || prename.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    var url = Uri.parse('http://regestrationrenion.atwebpages.com/sign_up.php');

    try {
      var response = await http.post(
        url,
        body: {
          'name': name,
          'prename': prename,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
        
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign up. Please try again later.')),
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
        title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Sora',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.person, color: Colors.white),
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
                        controller: prenameController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Prename',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Sora',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.person, color: Colors.white),
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
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email',
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
                          hintText: 'Password',
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
                          signUp(context);
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            color: Colors.white,
                          ),
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
