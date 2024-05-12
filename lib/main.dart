import 'package:flutter/material.dart';
import 'package:sgovs_desktop/home/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
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
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 100,width: 200,child : Image.asset(
                    'assets/images/l1.png',
                    fit: BoxFit.cover,
                  ),),
                    SizedBox(height: 20,),
                    const Text(
                      "System Gouvernance Solution ",
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(28, 120, 117, 1),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "“Empowering governance\n Accelerate success”",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20,
                        color: Color.fromRGBO(58, 65, 69, 1)
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                           color : Color.fromRGBO(28, 120, 117, 1),
                           borderRadius: BorderRadius.circular(20),
                      ),
                      height:40 ,
                      width:180 ,
                        child: Center(child: Text('Commencer',style: TextStyle(fontFamily: 'Sora',fontSize: 18, color: Colors.white,),)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/4.png',
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Center(
                      child: SizedBox(
                        width: 400,height: 400,
                        child: Image.asset(
                          'assets/images/3.png',
                          
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
