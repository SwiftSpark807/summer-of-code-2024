import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/components/toast.dart';

class FireBaseAuthServices {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-exits') {
        showToast(message: 'This is email is already in use');
      } else {
        showToast(message: 'error occured :  ${e.code}');
      }
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-password') {
        showToast(message: 'Invalid email or password');
      } else {
        showToast(message: 'An error occured : ${e.code}');
      }
    }
    return null;
  }
}
