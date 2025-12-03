import 'package:track2drive/features/auth/domain/repositories/auth_repository.dart';

class SendResetEmailUseCase {
  final AuthRepository _repository;

  SendResetEmailUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.sendResetEmail(email);
  }
}
