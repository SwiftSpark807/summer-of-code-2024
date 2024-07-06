import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'signup.dart';
import 'main.dart'; // Assuming login and signup pages are in main.dart

String finalEmail = "";
Map<String, dynamic> userData = {};

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    getValidation().whenComplete(() async {
      Timer(
          Duration(seconds: 2),
          () => Get.to(finalEmail == "null"
              ? PosSystem()
              : HomePage(
                  userData: userData,
                )));
    });
    super.initState();
  }

  Future getValidation() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedEmail = sharedPreferences.getString('email');

    setState(() {
      finalEmail = obtainedEmail.toString();
    });
    String? jsonString = sharedPreferences.getString(finalEmail);
    if (jsonString != null) userData = jsonDecode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
