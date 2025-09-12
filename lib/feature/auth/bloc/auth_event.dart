part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSignIn extends AuthEvent {
  final String email;
  final String password;
  const AuthSignIn(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const AuthSignUp(this.email, this.password, this.name);
  @override
  List<Object?> get props => [email, password, name];
}

final class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

