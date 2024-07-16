import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: SizedBox(
            width: 306,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(180.0)),
                  errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                  contentPadding: EdgeInsets.all(15.0),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(180.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(180.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(180.0),
                  ),
                  fillColor: const Color.fromRGBO(248, 240, 229, 1),
                  filled: true,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 147, 147, 147)
                        .withOpacity(0.7),
                  )),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return hintText;
                }
                return null;
              },
            )));
  }
}
