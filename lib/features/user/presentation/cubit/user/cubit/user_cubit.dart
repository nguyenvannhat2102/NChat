import 'package:bloc/bloc.dart';
import 'package:chat/features/user/domain/entities/user_entity.dart';
import 'package:chat/features/user/domain/use_cases/user/get_all_users_usecase.dart';
import 'package:chat/features/user/domain/use_cases/user/update_user_usecase.dart';
import 'package:equatable/equatable.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UpdateUserUseCase updateUserUseCase;
  final GetAllUsersUseCase getAllUsersUseCase;
  UserCubit({
    required this.updateUserUseCase,
    required this.getAllUsersUseCase,
  }) : super(UserInitial());

  Future<void> getAllUsers() async {
    emit(UserLoading());
    final streamResponse = getAllUsersUseCase.call();
    streamResponse.listen((users) {
      emit(UserLoaded(users: users));
    });
  }

  Future<void> updateUser({required UserEntity user}) async {
    try {
      await updateUserUseCase.call(user);
    } catch (e) {
      emit(UserFailure());
    }
  }
}
