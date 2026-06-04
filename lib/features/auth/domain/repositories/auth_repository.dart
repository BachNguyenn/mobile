import 'package:mobile/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  Future<AuthUser?> signInWithGoogle();
  Future<AuthUser?> signInAnonymously();
  Future<AuthUser?> signInWithEmail(String email, String password);
  Future<AuthUser?> signUpWithEmail(String email, String password);
  Future<void> signOut();
  AuthUser? get currentUser;
}
