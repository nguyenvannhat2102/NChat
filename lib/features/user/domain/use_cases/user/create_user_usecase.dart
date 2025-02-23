import 'package:chat/features/user/domain/entities/user_entity.dart';
import 'package:chat/features/user/domain/repository/user_repository.dart';

class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase({required this.repository});

  Future<void> call(UserEntity user) async {
    return repository.createUser(user);
  }
}
