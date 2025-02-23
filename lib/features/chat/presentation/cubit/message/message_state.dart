part of 'message_cubit.dart';

sealed class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {
  @override
  List<Object> get props => [];
}

class MessageLoaded extends MessageState {
  final List<MessageEntity> messages;

  const MessageLoaded({required this.messages});
  @override
  List<Object> get props => [messages];
}

class MessageFailure extends MessageState {
  @override
  List<Object> get props => [];
}
