import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc(this.repository) : super(const AuthState.unknown()) {
    on<AuthStarted>((event, emit) async {
      await emit.forEach<User?>(
        repository.authStateChanges(),
        onData: (u) => AuthState.authChanged(u),
      );
    });

    on<AuthSignIn>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        await repository.signIn(event.email, event.password);
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(errorMessage: e.message));
      } finally {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<AuthSignUp>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        await repository.signUp(event.email, event.password);
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(errorMessage: e.message));
      } finally {
        emit(state.copyWith(isLoading: false));
      }
    });

    on<AuthSignOut>((event, emit) async {
      await repository.signOut();
    });
  }
}

