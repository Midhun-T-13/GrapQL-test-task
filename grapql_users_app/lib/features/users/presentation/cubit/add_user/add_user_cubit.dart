import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_user.dart';
import 'add_user_state.dart';

class AddUserCubit extends Cubit<AddUserState> {
  final CreateUser createUserUseCase;

  AddUserCubit({required this.createUserUseCase}) : super(AddUserInitial());

  Future<void> createUser({
    required String name,
    required String username,
    required String email,
  }) async {
    emit(AddUserLoading());

    final result = await createUserUseCase(
      CreateUserParams(
        name: name,
        username: username,
        email: email,
      ),
    );

    result.fold(
      (failure) => emit(AddUserError(message: failure.message)),
      (user) => emit(AddUserSuccess(user: user)),
    );
  }

  void reset() {
    emit(AddUserInitial());
  }
}
