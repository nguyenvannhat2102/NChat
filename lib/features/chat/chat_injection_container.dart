import 'package:chat/features/chat/data/data_source/remote/chat_remote_datasource.dart';
import 'package:chat/features/chat/data/data_source/remote/chat_remote_datasource_impl.dart';
import 'package:chat/features/chat/data/repository/chat_repository_impl.dart';
import 'package:chat/features/chat/domain/repository/chat_repository.dart';
import 'package:chat/features/chat/domain/usecases/delete_message_usecase.dart';
import 'package:chat/features/chat/domain/usecases/delete_my_chat_usecase.dart';
import 'package:chat/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:chat/features/chat/domain/usecases/get_my_chat_usecase.dart';
import 'package:chat/features/chat/domain/usecases/seen_message_update_usecase.dart';
import 'package:chat/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:chat/features/chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:chat/features/chat/presentation/cubit/message/message_cubit.dart';
import 'package:chat/main_injection_container.dart';

Future<void> chatInjectionContainer() async {
  // * CUBITS INJECTION

  sl.registerFactory<ChatCubit>(() =>
      ChatCubit(getMyChatUseCase: sl.call(), deleteMyChatUseCase: sl.call()));

  sl.registerFactory<MessageCubit>(() => MessageCubit(
      getMessagesUseCase: sl.call(),
      deleteMessageUseCase: sl.call(),
      sendMessageUseCase: sl.call(),
      seenMessageUpdateUseCase: sl.call()));

  // * USE CASES INJECTION

  sl.registerLazySingleton<DeleteMessageUseCase>(
      () => DeleteMessageUseCase(repository: sl.call()));

  sl.registerLazySingleton<DeleteMyChatUseCase>(
      () => DeleteMyChatUseCase(repository: sl.call()));

  sl.registerLazySingleton<GetMessagesUseCase>(
      () => GetMessagesUseCase(repository: sl.call()));

  sl.registerLazySingleton<GetMyChatUseCase>(
      () => GetMyChatUseCase(repository: sl.call()));

  sl.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(repository: sl.call()));

  sl.registerLazySingleton<SeenMessageUpdateUseCase>(
      () => SeenMessageUpdateUseCase(repository: sl.call()));

  // * REPOSITORY & DATA SOURCES INJECTION

  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: sl.call()));

  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDatasourceImpl(
        fireStore: sl.call(),
      ));
}
