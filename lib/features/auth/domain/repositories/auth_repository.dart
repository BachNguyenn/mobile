import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserCredential> signInWithGoogle();
  Future<UserCredential> signInAnonymously();
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> signUpWithEmail(String email, String password);
  Future<void> signOut();
  User? get currentUser;
}
