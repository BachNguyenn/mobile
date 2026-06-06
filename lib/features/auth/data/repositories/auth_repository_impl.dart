import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/features/auth/domain/entities/auth_failure.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Future<void>? _googleSignInInitialization;

  @override
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toDomainUser);

  @override
  AuthUser? get currentUser => _toDomainUser(_auth.currentUser);

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();
      if (!_googleSignIn.supportsAuthenticate()) {
        throw const AuthFailure(AuthFailureCode.operationNotAllowed);
      }

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return _toDomainUser(result.user);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure(AuthFailureCode.canceled);
      }
      throw AuthFailure(
        AuthFailureCode.unknown,
        message: error.description ?? error.code.name,
      );
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  @override
  Future<AuthUser?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return _toDomainUser(result.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  @override
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toDomainUser(result.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  @override
  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toDomainUser(result.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseError(error);
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureGoogleSignInInitialized();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitialization ??= _googleSignIn.initialize();
  }

  AuthUser? _toDomainUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  AuthFailure _mapFirebaseError(FirebaseAuthException error) {
    final code = switch (error.code) {
      'email-already-in-use' => AuthFailureCode.emailAlreadyInUse,
      'invalid-credential' => AuthFailureCode.invalidCredential,
      'invalid-email' => AuthFailureCode.invalidEmail,
      'network-request-failed' => AuthFailureCode.networkRequestFailed,
      'operation-not-allowed' => AuthFailureCode.operationNotAllowed,
      'too-many-requests' => AuthFailureCode.tooManyRequests,
      'user-disabled' => AuthFailureCode.userDisabled,
      'user-not-found' => AuthFailureCode.userNotFound,
      'weak-password' => AuthFailureCode.weakPassword,
      'wrong-password' => AuthFailureCode.wrongPassword,
      _ => AuthFailureCode.unknown,
    };
    return AuthFailure(code, message: error.message ?? error.code);
  }
}
