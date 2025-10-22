import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/get_user_by_id.dart';
import 'user_detail_state.dart';

class UserDetailCubit extends Cubit<UserDetailState> {
  final GetUserById getUserById;

  UserDetailCubit({required this.getUserById}) : super(const UserDetailInitial());

  Future<void> loadUser(String userId) async {
    emit(const UserDetailLoading());

    final result = await getUserById(GetUserByIdParams(id: userId));

    result.fold(
      (failure) => emit(UserDetailError(message: failure.message)),
      (user) => emit(UserDetailDisplay(user: user)),
    );
  }

}
