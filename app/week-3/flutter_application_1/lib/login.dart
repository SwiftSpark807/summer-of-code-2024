import 'package:flutter/material.dart';
import 'package:flutter_application_1/AdminHome.dart';
import 'package:flutter_application_1/components/textfield.dart';
import 'package:flutter_application_1/components/toast.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/loading_provider.dart';
import 'package:flutter_application_1/user_auth/auth_implementation/firebase_auth_implementation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup.dart';
import 'FormAfterGoogle.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPage createState() => _SecondPage();
}

class _SecondPage extends State<SecondPage> {
  final FireBaseAuthServices _auth = FireBaseAuthServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLogginIn = false;

  Future<void> login(BuildContext context) async {
    setState(() {
      isLogginIn = true;
    });
    if (!_formKey.currentState!.validate()) {
      setState(() {
        isLogginIn = false;
      });
      return;
    }

    String email = emailController.text;
    String password = passWordController.text;
    User? user = await _auth.signInWithEmailAndPassword(email, password);
    setState(() {
      isLogginIn = false;
    });
    if (user != null) {
      print("Logged In");
      final userRef =
          await FirebaseFirestore.instance.collection('Users').doc(email).get();
      final userData = userRef.data();
      if (userData!['access'] == 'cashier') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AdminProfile()));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Successful')),
      );
    } else {
      print("some error");
    }
  }

  Future<void> _sigInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        final User? user = userCredential.user;
        if (user != null) {
          final userEmail = user.email!;
          // Get the user's document from Firestore using email as ID
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userEmail)
              .get();

          if (!userDoc.exists) {
            // If user document does not exist, create it with email as ID
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(userEmail)
                .set({
              'name': user.displayName,
              'email': userEmail,
              'phoneNumber': user.phoneNumber, // Add other fields as needed
            });
          }

          // Check if any required fields are null
          final data = userDoc.data();
          if (data != null) {
            final isDataComplete = data['name'] != null &&
                data['access'] != null &&
                data['password'] != null &&
                data['phoneNumber'] != null; // Add other fields as needed

            if (isDataComplete) {
              // All fields are complete, navigate to HomePage
              if (data['access'] == 'cashier') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              } else {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AdminProfile()));
              }
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Login Successful')));
            } else {
              print(data["email"]);
              // Fields are missing, navigate to CredPage
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CredPage(
                            email: userEmail,
                          )));
            }
          } else {
            print("Hello");
            // No data found, navigate to CredPage
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CredPage(
                          email: userEmail,
                        )));
          }
        }
      }
    } catch (e) {
      showToast(message: "some error occured : ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadingProvider = Provider.of<LoadingProvider>(context);

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
                  child: Text('POS  ',
                      style: TextStyle(
                          fontFamily: "JockeyOne",
                          color: Colors.white,
                          fontSize: 30)))),
          centerTitle: false,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 71),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(49, 0, 0, 0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Welcome Back!",
                                    style: TextStyle(
                                        fontFamily: "JockeyOne",
                                        color: Colors.white,
                                        fontSize: 33.35)))),
                        SizedBox(height: 16),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(49, 0, 0, 0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Login to continue",
                                    style: TextStyle(
                                        fontFamily: "Inter",
                                        color: Colors.white,
                                        fontSize: 14.8)))),
                        SizedBox(height: 51),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(49, 0, 0, 0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Email",
                                    style: TextStyle(
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontSize: 18.8)))),
                        SizedBox(height: 12),
                        MyTextfield(
                          controller: emailController,
                          hintText: "Email",
                          obscureText: false,
                        ),
                        SizedBox(height: 48.5),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(49, 0, 0, 0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Password",
                                    style: TextStyle(
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontSize: 18.8)))),
                        SizedBox(height: 12),
                        MyTextfield(
                            controller: passWordController,
                            hintText: "password",
                            obscureText: true),
                        SizedBox(height: 12),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("Forget Password?",
                                    style: TextStyle(
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 11.1))
                              ],
                            )),
                        SizedBox(
                          height: 30.0,
                        ),
                        SizedBox(
                            width: 306.0,
                            height: 50.0,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(218, 192, 163, 1),
                                ),
                                onPressed: () {
                                  login(context);
                                },
                                child: isLogginIn
                                    ? CircularProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : Text("Login",
                                        style: TextStyle(
                                            fontFamily: "Inter",
                                            fontWeight: FontWeight.w900,
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            fontSize: 20)))),
                        SizedBox(height: 12),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                style: ButtonStyle(),
                                onPressed: () {
                                  _sigInWithGoogle();
                                },
                                icon: Image.asset('assests/images/google.png',
                                    width: 70, height: 70),
                                label: Text(
                                  'Sign in with google',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                            ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account ?",
                                style: TextStyle(
                                    fontFamily: "Inter",
                                    color: Colors.white,
                                    fontSize: 14)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupPage()));
                              },
                              child: Text("Sign Up",
                                  style: TextStyle(
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: const Color.fromRGBO(
                                          218, 192, 163, 1),
                                      decorationThickness: 2,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      color: const Color.fromRGBO(
                                          218, 192, 163, 1),
                                      fontSize: 14)),
                            )
                          ],
                        ),
                      ],
                    ))),
          ),
          if (loadingProvider.isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
