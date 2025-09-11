part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final User? user;
  const AuthState({
    required this.isLoading,
    required this.errorMessage,
    required this.user,
  });

  const AuthState.unknown()
    : this(isLoading: false, errorMessage: null, user: null);

  factory AuthState.authChanged(User? user) =>
      AuthState(isLoading: false, errorMessage: null, user: user);

  AuthState copyWith({bool? isLoading, String? errorMessage, User? user}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        user: user ?? this.user,
      );

  @override
  List<Object?> get props => [isLoading, errorMessage, user?.uid];
}

