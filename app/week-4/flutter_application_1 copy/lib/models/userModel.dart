import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String? name;
  final String? password;
  final String? phoneNumber;
  final String? access;

  MyUser({
    this.name,
    this.phoneNumber,
    required this.password,
    this.access,
  });

  factory MyUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MyUser(
      name: data?['name'],
      phoneNumber: data?['phoneNumber'],
      password: data?['password'],
      access: data?['access'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
      if (phoneNumber == null) "phoneNumber": "",
      if (password != null) "password": password,
      if (access != null) "access": access,
    };
  }
}
