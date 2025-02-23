import 'package:chat/features/chat/chat_injection_container.dart';
import 'package:chat/features/user/user_injection_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final firebaseMessaging = FirebaseMessaging.instance;

  sl.registerLazySingleton(() => auth);
  sl.registerLazySingleton(() => fireStore);
  sl.registerLazySingleton(() => firebaseMessaging);

  await userInjectionContainer();
  await chatInjectionContainer();
}
