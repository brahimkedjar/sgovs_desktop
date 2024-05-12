import 'package:flutter/material.dart';
import 'package:sgovs_desktop/home/cree_vote/CreateVotePage.dart';
import 'package:sgovs_desktop/home/gerer_utilisateurs/manage_users_page.dart';
import 'package:sgovs_desktop/home/login.dart';
import 'package:sgovs_desktop/home/orgnize_renion/Orgnize_Renion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    setState(() {
      isLoggedIn = false;
    });
    // Navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
 
  automaticallyImplyLeading: false, // This line removes the back button
  actions: [
    if (isLoggedIn)
      IconButton(
        onPressed: () {
          logout();
        },
        icon: const Icon(Icons.logout),
      ),
  ],
),

      body: Container(
        decoration: const BoxDecoration(
          
        ),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the user management page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageUsersPage()),
                  );
                },
                child: const Text('Gérer les utilisateurs'),
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              height: 280, // Set a fixed height for the row
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Orgnize_Renion(title: 'Organiser une réunion')),
                        );
                      },
                      child:Container(
                      padding:EdgeInsets.all(20) ,
                     
                      width: 200,
                      decoration: BoxDecoration(
                                 color: Color.fromRGBO(28, 120, 117, 0.8),
                                 borderRadius: BorderRadius.circular(20),
                            ),
                      child: Column(mainAxisAlignment:MainAxisAlignment.center ,
                        children: [ 
                        SizedBox(width:150,height : 100, child :Image.asset('assets/images/v.png' ,)),
                        SizedBox(height: 10,),
                        Text("Organiser une Réunion",style: TextStyle(fontFamily: 'Sora',fontSize: 20,fontWeight: FontWeight.bold, color: Colors.white,),),
                      ]), 
                                   ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateVotePage()),
                        );
                      },
                      child:Container(
                      padding:EdgeInsets.all(20) ,
                     
                      width: 200,
                      decoration: BoxDecoration(
                                 color: Color.fromRGBO(28, 120, 117, 0.8),
                                 borderRadius: BorderRadius.circular(20),
                            ),
                      child: Column(mainAxisAlignment:MainAxisAlignment.center ,
                        children: [ 
                        SizedBox(width:150,height : 100, child :Image.asset('assets/images/v2.png' ,)),
                        SizedBox(height: 10,),
                        Text("Créer un Vote",style: TextStyle(fontFamily: 'Sora',fontSize: 20,fontWeight: FontWeight.bold, color: Colors.white,),),
                      ]), 
                                   ),
                    ),
                    GestureDetector(
                      onTap: () {
                       // Navigator.push(context,MaterialPageRoute(builder: (context) => const Orgnize_Renion(title: 'Créer un sondage')),);
                      },
                      child:Container(
                      padding:EdgeInsets.all(20) ,
                     
                      width: 200,
                      decoration: BoxDecoration(
                                 color: Color.fromRGBO(28, 120, 117, 0.8),
                                 borderRadius: BorderRadius.circular(20),
                            ),
                      child: Column(mainAxisAlignment:MainAxisAlignment.center ,
                        children: [ 
                        SizedBox(width:150,height : 100, child :Image.asset('assets/images/bb2.png' ,)),
                        SizedBox(height: 10,),
                        Text("Bibliothèque \n numérique",style: TextStyle(fontFamily: 'Sora',fontSize: 20,fontWeight: FontWeight.bold, color: Colors.white,),),
                      ]), 
                                   ),
                    ),
                    GestureDetector(
                      onTap: () {
                       // Navigator.push(context,MaterialPageRoute(builder: (context) => const Orgnize_Renion(title: 'Bourse')),);
                      },
                      child:Container(
                      padding:EdgeInsets.all(20) ,
                     
                      width: 200,
                      decoration: BoxDecoration(
                                 color: Color.fromRGBO(28, 120, 117, 0.8),
                                 borderRadius: BorderRadius.circular(20),
                            ),
                      child: Column(mainAxisAlignment:MainAxisAlignment.center ,
                        children: [ 
                        SizedBox(width:150,height : 100, child :Image.asset('assets/images/b2.png' ,)),
                        SizedBox(height: 10,),
                        Text("Bourses",style: TextStyle(fontFamily: 'Sora',fontSize: 20,fontWeight: FontWeight.bold, color: Colors.white,),),
                      ]), 
                                   ),
                    ),
                   
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureContainer(String text, String imagePath) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
