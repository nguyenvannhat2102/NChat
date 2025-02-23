import 'package:chat/features/app/home/home_page.dart';
import 'package:chat/features/app/splash/splash_screen.dart';
import 'package:chat/features/app/theme/style.dart';
import 'package:chat/features/chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:chat/features/chat/presentation/cubit/message/message_cubit.dart';
import 'package:chat/features/user/presentation/cubit/auth/cubit/auth_cubit.dart';
import 'package:chat/features/user/presentation/cubit/credential/cubit/credential_cubit.dart';
import 'package:chat/features/user/presentation/cubit/get_device_number/cubit/get_device_number_cubit.dart';
import 'package:chat/features/user/presentation/cubit/get_single_user/cubit/get_single_user_cubit.dart';
import 'package:chat/features/user/presentation/cubit/user/cubit/user_cubit.dart';
import 'package:chat/firebase_options.dart';
import 'package:chat/routes/on_genergate_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  await di.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthCubit>()..appStarted(),
        ),
        BlocProvider(
          create: (context) => di.sl<CredentialCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<GetSingleUserCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<UserCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<GetDeviceNumberCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<ChatCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<MessageCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(
            color: appBarColor,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: whiteColor),
        ),
        initialRoute: "/",
        onGenerateRoute: OnGenerateRouter.route,
        routes: {
          "/": (context) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return HomePage(
                    uid: state.uid,
                  );
                }
                return const SplashScreen();
              },
            );
          },
        },
      ),
    );
  }
}
