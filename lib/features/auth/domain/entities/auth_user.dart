import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, isAnonymous];
}
