import 'package:flutter/material.dart';

class MyLabel extends StatelessWidget {
  final String check;

  const MyLabel({super.key, required this.check});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(49, 0, 0, 0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(check,
                style: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 18.58))));
  }
}
