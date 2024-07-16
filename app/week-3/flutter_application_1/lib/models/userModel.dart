import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String? name;
  final String? phoneNumber;

  MyUser({
    this.name,
    this.phoneNumber,
  });

  factory MyUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return MyUser(
      name: data?['name'],
      phoneNumber: data?['phoneNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "name": name,
      if (phoneNumber != null) "phoneNumber": phoneNumber,
      if (phoneNumber == null) "phoneNumber": "",
    };
  }
}
