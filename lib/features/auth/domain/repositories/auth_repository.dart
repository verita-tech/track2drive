import 'package:track2drive/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password);
  Future<void> sendResetEmail(String email);
  Future<void> logout();
  Stream<UserEntity?> authStateChanges();
}
