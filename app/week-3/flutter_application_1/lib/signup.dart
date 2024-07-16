import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/textLabel.dart';
import 'package:flutter_application_1/components/textfield.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/user_auth/auth_implementation/firebase_auth_implementation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/userModel.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPage createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  final FireBaseAuthServices _auth = FireBaseAuthServices();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController admnController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<void> saveUsernameToFirestore(String uid, String username) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': username,
    });
  }

  Future<void> signup() async {
    String username = fullNameController.text;
    String email = emailController.text;
    String password = passWordController.text;

    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      await saveUsernameToFirestore(user.uid, username);
      print("User created");
    } else {
      print("some error");
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final newUser = MyUser(
      phoneNumber: phoneController.text,
      name: fullNameController.text,
    );
    final docRef = FirebaseFirestore.instance
        .collection("Users")
        .doc(userCredential.user!.email!)
        .withConverter(
          fromFirestore: MyUser.fromFirestore,
          toFirestore: (MyUser newUser, options) => newUser.toFirestore(),
        );

    await docRef.set(newUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup Successful')),
    );

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(16, 44, 87, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(82.0), // Set the height here
          child: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white, //change your color here
            ),
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
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(49, 0, 0, 0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Create Account Now !",
                                  style: TextStyle(
                                      fontFamily: "JockeyOne",
                                      color: Colors.white,
                                      fontSize: 33.35)))),
                      SizedBox(height: 39),
                      MyLabel(check: "Full Name"),
                      SizedBox(height: 12),
                      MyTextfield(
                        controller: fullNameController,
                        hintText: "Enter You Full Name",
                        obscureText: false,
                      ),
                      SizedBox(height: 39),
                      MyLabel(check: "Email"),
                      SizedBox(height: 12),
                      MyTextfield(
                        controller: emailController,
                        hintText: "Email",
                        obscureText: false,
                      ),
                      SizedBox(height: 39),
                      MyLabel(check: "Password"),
                      SizedBox(height: 12),
                      MyTextfield(
                          controller: passWordController,
                          hintText: "password",
                          obscureText: true),
                      SizedBox(height: 39),
                      MyLabel(check: "Phone No"),
                      SizedBox(height: 12),
                      MyTextfield(
                        controller: phoneController,
                        hintText: "Enter your phone no",
                        obscureText: false,
                      ),
                      SizedBox(height: 12),
                      MyTextfield(
                        controller: admnController,
                        hintText: "Admin/Cashier",
                        obscureText: false,
                      ),
                      SizedBox(height: 50),
                      SizedBox(
                          width: 306.0,
                          height: 50.0,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(218, 192, 163, 1),
                              ),
                              onPressed: () {
                                signup();
                              },
                              child: Text("Sign Up",
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w900,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 20)))),
                    ],
                  ))),
        ));
  }

  void _signUp() async {}
}
