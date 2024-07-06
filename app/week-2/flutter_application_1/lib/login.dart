import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/textfield.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/loading_provider.dart';
import 'package:provider/provider.dart';
import 'signup.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPage createState() => _SecondPage();
}

class _SecondPage extends State<SecondPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> login(BuildContext context) async {
    final loadingProvider =
        Provider.of<LoadingProvider>(context, listen: false);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = emailController.text;
    String password = passWordController.text;
    loadingProvider.startLoading();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(email);

      if (jsonString != null) {
        Map<String, dynamic> userData = jsonDecode(jsonString);
        if (userData['password'] == password) {
          // Login successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Successful')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userData: userData,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          // Wrong password
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong Password')),
          );
        }
      } else {
        // No user found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found with this email')),
        );
      }
    } finally {
      loadingProvider.stopLoading();
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
                  child: Text('POS  ',
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
                        SizedBox(height: 48),
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
                                child: Text("Login",
                                    style: TextStyle(
                                        fontFamily: "Inter",
                                        fontWeight: FontWeight.w900,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 20)))),
                        SizedBox(height: 12),
                        SizedBox(height: 46),
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
