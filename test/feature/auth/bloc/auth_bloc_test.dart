import 'package:aeza_flutter/feature/auth/bloc/auth_bloc.dart';
import 'package:aeza_flutter/data/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockUser extends Mock implements User {}

void main() {
  setUpAll(() {
    registerFallbackValue(FirebaseAuthException(code: 'unknown'));
  });

  group('AuthBloc', () {
    late _MockAuthRepository repo;

    setUp(() {
      repo = _MockAuthRepository();
    });

    test('initial state is unknown', () {
      expect(AuthBloc(repo).state, const AuthState.unknown());
    });

    blocTest<AuthBloc, AuthState>(
      'emits authChanged on AuthStarted with user stream',
      build: () {
        final mockUser = _MockUser();
        when(() => mockUser.uid).thenReturn('uid-1');
        when(
          () => repo.authStateChanges(),
        ).thenAnswer((_) => Stream<User?>.fromIterable([null, mockUser]));
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        isA<AuthState>().having((s) => s.user, 'user', null),
        isA<AuthState>().having((s) => s.user, 'user', isA<User>()),
      ],
      verify: (_) {
        verify(() => repo.authStateChanges()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'sign in success toggles loading',
      build: () {
        when(
          () => repo.signIn(any(), any()),
        ).thenAnswer((_) async => _FakeUserCredential());
        when(
          () => repo.authStateChanges(),
        ).thenAnswer((_) => const Stream<User?>.empty());
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthSignIn('e@e.com', 'password123')),
      expect: () => [
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'sign in failure sets error and toggles loading',
      build: () {
        when(() => repo.signIn(any(), any())).thenThrow(
          FirebaseAuthException(
            code: 'auth/invalid-credential',
            message: 'Invalid',
          ),
        );
        when(
          () => repo.authStateChanges(),
        ).thenAnswer((_) => const Stream<User?>.empty());
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthSignIn('e@e.com', 'bad')),
      expect: () => [
        // loading started
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
        // error set while still loading (finally will toggle)
        isA<AuthState>()
            .having((s) => s.errorMessage, 'error', 'Invalid')
            .having((s) => s.isLoading, 'isLoading', true),
        // loading finished, error cleared by copyWith(null)
        isA<AuthState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'error', null),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'sign up success toggles loading',
      build: () {
        when(
          () => repo.signUp(any(), any(), any()),
        ).thenAnswer((_) async => _FakeUserCredential());
        when(
          () => repo.authStateChanges(),
        ).thenAnswer((_) => const Stream<User?>.empty());
        return AuthBloc(repo);
      },
      act: (bloc) =>
          bloc.add(const AuthSignUp('e@e.com', 'password123', 'Name')),
      expect: () => [
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', true),
        isA<AuthState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );
  });
}

class _FakeUserCredential implements UserCredential {
  @override
  AuthCredential? get credential => null;
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
  @override
  ConfirmationResult? get confirmationResult => null;
  @override
  User? get user => null;
}
