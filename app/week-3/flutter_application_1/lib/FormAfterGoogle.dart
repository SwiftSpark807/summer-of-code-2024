import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/textLabel.dart';
import 'package:flutter_application_1/components/textfield.dart';
import 'package:flutter_application_1/home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/userModel.dart';

class CredPage extends StatefulWidget {
  final String email;

  CredPage({required this.email});

  @override
  _CredPage createState() => _CredPage();
}

class _CredPage extends State<CredPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController admnController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
  }

  Future<void> updateDetails() async {
    String username = fullNameController.text;
    String password = passWordController.text;
    String phoneNo = phoneController.text;
    String position = admnController.text;
    final myUser = MyUser(
        name: username,
        password: password,
        phoneNumber: phoneNo,
        access: position);
    final docRef = position.toLowerCase() == 'cashier'
        ? FirebaseFirestore.instance
            .collection("Cashiers")
            .doc(widget.email)
            .withConverter(
                fromFirestore: MyUser.fromFirestore,
                toFirestore: (MyUser myUser, options) => myUser.toFirestore())
        : FirebaseFirestore.instance
            .collection("Admins")
            .doc(widget.email)
            .withConverter(
                fromFirestore: MyUser.fromFirestore,
                toFirestore: (MyUser myUser, options) => myUser.toFirestore());
    await docRef.set(myUser);
    final docref = FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.email)
        .withConverter(
            fromFirestore: MyUser.fromFirestore,
            toFirestore: (MyUser myUser, options) => myUser.toFirestore());
    await docref.set(myUser);
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
                      MyLabel(check: widget.email),
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
                                updateDetails();
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
