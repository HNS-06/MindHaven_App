// import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static bool get isLoggedIn => false; // Mock for testing
}