import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  AuthRepository(this._auth);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp(String email, String password, String name) async {
    UserCredential user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await user.user!.updateDisplayName(name);
    await user.user!.reload();
    return user;
  }

  Future<void> signOut() => _auth.signOut();
}

