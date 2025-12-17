import 'package:track2drive/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:track2drive/features/auth/domain/entities/user_entity.dart';
import 'package:track2drive/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<UserEntity> login(String email, String password) {
    return remote.signIn(email, password);
  }

  @override
  Future<UserEntity> register(String email, String password) {
    return remote.register(email, password);
  }

  @override
  Future<void> sendResetEmail(String email) {
    return remote.sendPasswordResetEmail(email);
  }

  @override
  Future<void> logout() {
    return remote.signOut();
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return remote.authStateChanges();
  }
}
