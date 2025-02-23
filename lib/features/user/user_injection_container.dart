import 'package:chat/features/user/data/data_sources/remote/user_remote_data_source.dart';
import 'package:chat/features/user/data/data_sources/remote/user_remote_data_source_impl.dart';
import 'package:chat/features/user/data/repository/repository_impl.dart';
import 'package:chat/features/user/domain/repository/user_repository.dart';
import 'package:chat/features/user/domain/use_cases/credential/get_curent_uid_usecase.dart';
import 'package:chat/features/user/domain/use_cases/credential/is_sign_in_usecase.dart';
import 'package:chat/features/user/domain/use_cases/credential/sign_in_with_phone_number_usecase.dart';
import 'package:chat/features/user/domain/use_cases/credential/sign_out_usecase.dart';
import 'package:chat/features/user/domain/use_cases/credential/verify_phone_number_usecase.dart';
import 'package:chat/features/user/domain/use_cases/user/create_user_usecase.dart';
import 'package:chat/features/user/domain/use_cases/user/get_all_users_usecase.dart';
import 'package:chat/features/user/domain/use_cases/user/get_device_number_usecase.dart';
import 'package:chat/features/user/domain/use_cases/user/get_single_user_usecase.dart';
import 'package:chat/features/user/domain/use_cases/user/update_user_usecase.dart';
import 'package:chat/features/user/presentation/cubit/auth/cubit/auth_cubit.dart';
import 'package:chat/features/user/presentation/cubit/credential/cubit/credential_cubit.dart';
import 'package:chat/features/user/presentation/cubit/get_device_number/cubit/get_device_number_cubit.dart';
import 'package:chat/features/user/presentation/cubit/get_single_user/cubit/get_single_user_cubit.dart';
import 'package:chat/features/user/presentation/cubit/user/cubit/user_cubit.dart';
import 'package:chat/main_injection_container.dart';

Future<void> userInjectionContainer() async {
  // * Cubit injection
  sl.registerFactory<AuthCubit>(() => AuthCubit(
        getCurrentUidUseCase: sl.call(),
        isSignInUseCase: sl.call(),
        signOutUseCase: sl.call(),
      ));

  sl.registerFactory<UserCubit>(() => UserCubit(
        getAllUsersUseCase: sl.call(),
        updateUserUseCase: sl.call(),
      ));

  sl.registerFactory<GetSingleUserCubit>(() => GetSingleUserCubit(
        getSingleUserUseCase: sl.call(),
      ));

  sl.registerFactory<CredentialCubit>(() => CredentialCubit(
        createUserUseCase: sl.call(),
        signInWithPhoneNumberUseCase: sl.call(),
        verifyPhoneNumberUseCase: sl.call(),
      ));

  sl.registerFactory<GetDeviceNumberCubit>(() => GetDeviceNumberCubit(
        getDeviceNumberUseCase: sl.call(),
      ));
  // * USE CASES injection

  sl.registerLazySingleton<GetCurrentUidUseCase>(
      () => GetCurrentUidUseCase(repository: sl.call()));

  sl.registerLazySingleton<IsSignInUseCase>(
      () => IsSignInUseCase(repository: sl.call()));

  sl.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(repository: sl.call()));

  sl.registerLazySingleton<CreateUserUseCase>(
      () => CreateUserUseCase(repository: sl.call()));

  sl.registerLazySingleton<GetAllUsersUseCase>(
      () => GetAllUsersUseCase(repository: sl.call()));

  sl.registerLazySingleton<UpdateUserUseCase>(
      () => UpdateUserUseCase(repository: sl.call()));

  sl.registerLazySingleton<GetSingleUserUseCase>(
      () => GetSingleUserUseCase(repository: sl.call()));

  sl.registerLazySingleton<SignInWithPhoneNumberUseCase>(
      () => SignInWithPhoneNumberUseCase(repository: sl.call()));

  sl.registerLazySingleton<VerifyPhoneNumberUseCase>(
      () => VerifyPhoneNumberUseCase(repository: sl.call()));

  sl.registerLazySingleton<GetDeviceNumberUseCase>(
      () => GetDeviceNumberUseCase(repository: sl.call()));

  // * REPOSITORY & DATA SOURCES INJECTION

  sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remoteDataSource: sl.call()));

  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(
        firebaseAuth: sl.call(),
        firebaseFirestore: sl.call(),
      ));
}
