import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String text1;
  final double size;
  final void Function()? func;
  const MyCard({
    super.key,
    required this.text1,
    required this.size,
    required this.func,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: ListTile(
        minLeadingWidth: 10,
        trailing: IconButton(
          onPressed: func,
          icon: Icon(
            Icons.edit,
            size: 20,
          ),
          color: const Color.fromARGB(255, 22, 22, 22),
        ),
        title: Text(
          text1,
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
    );
  }
}
