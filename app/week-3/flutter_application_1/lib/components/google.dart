import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireBaseAuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Check if user exists in Firestore
  Future<bool> doesUserExist(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return querySnapshot.size > 0;
  }

  // Create a new user document in Firestore
  Future<void> createUserDocument(String email, String name) async {
    await _firestore.collection('users').doc(email).set({
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
