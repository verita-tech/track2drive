import 'package:firebase_auth/firebase_auth.dart';
import 'package:track2drive/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email});

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
    ); // Mappt Firebase‑User auf deine Entity.[web:82]
  }
}
