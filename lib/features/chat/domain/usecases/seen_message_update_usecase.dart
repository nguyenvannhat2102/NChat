import 'package:chat/features/chat/domain/entities/message_entity.dart';
import 'package:chat/features/chat/domain/repository/chat_repository.dart';

class SeenMessageUpdateUseCase {
  final ChatRepository repository;

  SeenMessageUpdateUseCase({required this.repository});

  Future<void> call(MessageEntity message) async {
    return await repository.seenMessageUpdate(message);
  }
}
