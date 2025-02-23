import 'package:bloc/bloc.dart';
import 'package:chat/features/user/domain/entities/contact_entity.dart';
import 'package:chat/features/user/domain/use_cases/user/get_device_number_usecase.dart';
import 'package:equatable/equatable.dart';

part 'get_device_number_state.dart';

class GetDeviceNumberCubit extends Cubit<GetDeviceNumberState> {
  final GetDeviceNumberUseCase getDeviceNumberUseCase;
  GetDeviceNumberCubit({required this.getDeviceNumberUseCase})
      : super(GetDeviceNumberInitial());

  Future<void> getDeviceNumber() async {
    try {
      final contactNumbers = await getDeviceNumberUseCase.call();
      emit(GetDeviceNumberLoaded(contacts: contactNumbers));
    } catch (_) {
      emit(GetDeviceNumberFailure());
    }
  }
}
