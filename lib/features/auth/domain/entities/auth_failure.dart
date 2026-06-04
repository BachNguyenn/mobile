enum AuthFailureCode {
  canceled,
  emailAlreadyInUse,
  invalidCredential,
  invalidEmail,
  networkRequestFailed,
  operationNotAllowed,
  tooManyRequests,
  userDisabled,
  userNotFound,
  weakPassword,
  wrongPassword,
  unknown,
}

class AuthFailure implements Exception {
  final AuthFailureCode code;
  final String? message;

  const AuthFailure(this.code, {this.message});

  @override
  String toString() {
    final detail = message?.trim();
    if (detail == null || detail.isEmpty) {
      return 'AuthFailure($code)';
    }
    return 'AuthFailure($code): $detail';
  }
}
