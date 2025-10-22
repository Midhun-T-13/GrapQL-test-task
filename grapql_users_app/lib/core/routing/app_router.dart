import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grapql_users_app/features/users/presentation/cubit/add_user/add_user_cubit.dart';
import 'package:grapql_users_app/features/users/presentation/screens/add_user_screen.dart';
import 'package:grapql_users_app/features/users/presentation/screens/user_detail_screen.dart';
import '../../app_di.dart';
import '../../features/users/presentation/cubit/user_detail/user_detail_cubit.dart';
import '../../features/users/presentation/cubit/user_list/user_list_cubit.dart';
import '../../features/users/presentation/screens/home_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String userDetail = '/user-detail';
  static const String addUser = '/add-user';


  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<UserListCubit>(
                create: (_) => getIt<UserListCubit>(),
              ),
              BlocProvider<AddUserCubit>(
                create: (_) => getIt<AddUserCubit>(),
              ),
            ],
            child:  const HomeScreen()
        ),
      ),
      GoRoute(
          path: '$userDetail/:userId',
          name: 'userDetail',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return BlocProvider(
              create: (_) => getIt<UserDetailCubit>()..loadUser(userId),
              child: const UserDetailScreen(),
            );
          },
      ),
      GoRoute(
        path: addUser,
        name: 'addUser',
        builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<UserListCubit>(
                create: (_) => getIt<UserListCubit>(),
              ),
              BlocProvider<AddUserCubit>(
                create: (_) => getIt<AddUserCubit>(),
              ),
            ],
            child:  const AddUserPage()

        ),
      ),

    ],
  );
}
