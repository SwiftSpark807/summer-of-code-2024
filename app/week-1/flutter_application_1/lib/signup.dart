import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/textLabel.dart';
import 'package:flutter_application_1/components/textfield.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPage createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String fullName = fullNameController.text;
    String email = emailController.text;
    String password = passWordController.text;
    String phone = phoneController.text;

    Map<String, dynamic> userData = {
      "fullName": fullName,
      "email": email,
      "password": password,
      "phone": phone,
    };

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(userData);
    await prefs.setString(email, jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup Successful')),
    );

    Navigator.pop(context);
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
                      SizedBox(height: 50),
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
}
