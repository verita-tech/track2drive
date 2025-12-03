import 'package:track2drive/features/auth/domain/entities/user_entity.dart';
import 'package:track2drive/features/auth/domain/repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;

  const RegisterParams({required this.email, required this.password});
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> call(RegisterParams params) {
    return _repository.register(params.email, params.password);
  }
}
