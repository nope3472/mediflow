import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with email and password.
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      developer.log('Starting email/password sign-in for email: ${email.trim()}');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      developer.log('Email/password sign-in successful: ${userCredential.user}');
      return userCredential;
    } catch (e, stacktrace) {
      developer.log('Error during email/password sign-in: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  // Create a user with email and password.
  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      developer.log('Starting user creation for email: ${email.trim()}');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      developer.log('User creation successful: ${userCredential.user}');
      return userCredential;
    } catch (e, stacktrace) {
      developer.log('Error during user creation: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  // Sign in with Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      developer.log('Starting Google Sign-In process');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        developer.log('Google Sign-In cancelled by user');
        return null;
      }
      developer.log('Google Sign-In successful, retrieving authentication details');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      developer.log('Google Sign-In complete: ${userCredential.user}');
      return userCredential;
    } catch (e, stacktrace) {
      developer.log('Error during Google Sign-In: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  // Get the current user.
  User? get currentUser => _auth.currentUser;

  // Sign out.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
