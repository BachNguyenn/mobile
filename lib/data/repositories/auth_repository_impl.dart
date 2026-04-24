import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/auth/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signInWithGoogle() async {
    // Logic for Google Sign In
    throw UnimplementedError('Google Sign In logic here');
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
