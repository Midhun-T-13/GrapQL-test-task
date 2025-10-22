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

  void toggleEditMode() {
    if (state is UserDetailDisplay) {
      final currentUser = (state as UserDetailDisplay).user;
      emit(UserDetailEditing(user: currentUser));
    } else if (state is UserDetailEditing || state is UserDetailUpdateError) {
      final currentUser = state is UserDetailEditing
          ? (state as UserDetailEditing).user
          : (state as UserDetailUpdateError).user;
      emit(UserDetailDisplay(user: currentUser));
    }
  }

  Future<void> updateUser({
    required String name,
    required String username,
    required String email,
    String? phone,
  }) async {
    if (state is! UserDetailEditing) return;

    final currentUser = (state as UserDetailEditing).user;
    emit(UserDetailUpdating(user: currentUser));

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Create updated user (Note: GraphQL Zero API doesn't persist updates)
    final updatedUser = UserEntity(
      id: currentUser.id,
      name: name,
      username: username,
      email: email,
      phone: phone,
      website: currentUser.website,
      companyName: currentUser.companyName,
      body: currentUser.body,
      street: currentUser.street,
      suite: currentUser.suite,
      city: currentUser.city,
      zipcode: currentUser.zipcode,
    );

    // Simulate success
    emit(UserDetailUpdateSuccess(user: updatedUser));

    // Switch back to display mode after a delay
    await Future.delayed(const Duration(milliseconds: 500));
    emit(UserDetailDisplay(user: updatedUser));
  }

  void resetToDisplay() {
    final currentUser = state is UserDetailDisplay
        ? (state as UserDetailDisplay).user
        : state is UserDetailEditing
            ? (state as UserDetailEditing).user
            : state is UserDetailUpdateError
                ? (state as UserDetailUpdateError).user
                : state is UserDetailUpdating
                    ? (state as UserDetailUpdating).user
                    : (state as UserDetailUpdateSuccess).user;

    emit(UserDetailDisplay(user: currentUser));
  }
}
