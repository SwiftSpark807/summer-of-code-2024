import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: PosSystem(),
    );
  }
}

class PosSystem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(82.0), // Set the height here
        child: AppBar(
          backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
          flexibleSpace: Container(
              padding: const EdgeInsets.fromLTRB(41, 0, 0, 0),
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('POS',
                      style: TextStyle(
                          fontFamily: "JockeyOne",
                          color: Colors.white,
                          fontSize: 30)))),
          centerTitle: false,
        ),
      ),
      body: SafeArea(
          child: Center(
              child: Column(
        children: [
          SizedBox(height: 47),
          Image.asset(
            'assests/images/home.png',
            width: 300,
            height: 230,
          ),
          SizedBox(height: 49),
          Text("Hello, Welcome!",
              style: TextStyle(
                  fontFamily: "JockeyOne", color: Colors.white, fontSize: 33)),
          SizedBox(height: 22),
          Text("Welcome to the portal",
              style: TextStyle(
                  fontFamily: "Inter", color: Colors.white, fontSize: 14.8)),
          SizedBox(height: 65),
          SizedBox(
              width: 330.0,
              height: 54.0,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(218, 192, 163, 1),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SecondPage()));
                  },
                  child: Text("Login",
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w900,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20)))),
          SizedBox(height: 24),
          SizedBox(
              width: 330.0,
              height: 54.0,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(218, 192, 163, 1),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignupPage()));
                  },
                  child: Text("Sign Up",
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w900,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 20)))),
          SizedBox(height: 46),
          Text("Or via Social Media",
              style: TextStyle(
                  fontFamily: "Inter", color: Colors.white, fontSize: 14)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              'assests/images/google.png',
              width: 70,
              height: 70,
            ),
            SizedBox(
              width: 30,
            ),
            Image.asset(
              'assests/images/facebook.png',
              width: 70,
              height: 70,
            ),
            SizedBox(
              width: 30,
            ),
            Image.asset(
              'assests/images/linkedin.png',
              width: 47,
              height: 47,
            ),
          ]),
        ],
      ))),
    );
  }
}
