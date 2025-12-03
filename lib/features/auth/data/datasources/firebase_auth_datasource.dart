import 'package:firebase_auth/firebase_auth.dart';
import 'package:track2drive/features/auth/data/models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> register(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Stream<UserModel?> authStateChanges();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserModel> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ); // Standard Email/Pass‑Login.[web:2][web:83]
    final user = credential.user!;
    return UserModel.fromFirebase(user);
  }

  @override
  Future<UserModel> register(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ); // Registrierung.[web:2][web:15]
    final user = credential.user!;
    return UserModel.fromFirebase(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(
      email: email,
    ); // Reset‑Mail.[web:83]
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut(); // Logout.[web:83]
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(
      (user) => user == null ? null : UserModel.fromFirebase(user),
    ); // User‑Stream.[web:83]
  }
}
