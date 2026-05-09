import 'package:firebase_auth/firebase_auth.dart';

/// AuthService - handles all Firebase Authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current logged-in user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (login/logout events)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Registers a new user with email and password
  /// Throws [FirebaseAuthException] on failure
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Signs in an existing user with email and password
  /// Throws [FirebaseAuthException] on failure
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Signs out the currently logged-in user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns a human-readable error message for Firebase auth errors
  String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
