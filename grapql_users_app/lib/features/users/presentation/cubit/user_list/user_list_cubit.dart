import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_users.dart';
import 'user_list_state.dart';

class UserListCubit extends Cubit<UserListState> {
  final GetUsers getUsersUseCase;
  static const int usersPerPage = 5;

  UserListCubit({required this.getUsersUseCase}) : super(UserListInitial());

  Future<void> loadPage(int page, {bool forceRefresh = false}) async {
    emit(UserListLoading());

    final result = await getUsersUseCase(
      GetUsersParams(
        page: page,
        limit: usersPerPage,
        forceRefresh: forceRefresh,
      ),
    );

    result.fold(
      (failure) => emit(UserListError(message: failure.message)),
      (result) {
        final totalPages = (result.totalCount / usersPerPage).ceil();
        emit(
          UserListLoaded(
            users: result.users,
            currentPage: page,
            totalPages: totalPages,
            hasNextPage: page < totalPages,
            hasPreviousPage: page > 1,
          ),
        );
      },
    );
  }

  Future<void> nextPage() async {
    if (state is UserListLoaded) {
      final currentState = state as UserListLoaded;
      if (currentState.hasNextPage) {
        await loadPage(currentState.currentPage + 1);
      }
    }
  }

  Future<void> previousPage() async {
    if (state is UserListLoaded) {
      final currentState = state as UserListLoaded;
      if (currentState.hasPreviousPage) {
        await loadPage(currentState.currentPage - 1);
      }
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1) {
      await loadPage(page);
    }
  }

  Future<void> refreshUsers() async {
    await loadPage(1, forceRefresh: true);
  }
}
