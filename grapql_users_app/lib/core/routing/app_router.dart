import 'package:go_router/go_router.dart';
import 'package:grapql_users_app/features/users/presentation/screens/add_user_screen.dart';
import 'package:grapql_users_app/features/users/presentation/screens/user_detail_screen.dart';
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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
          path: userDetail,
          name: 'userDetail',
          builder: (context, state) => UserDetailScreen()
      ),
      GoRoute(
        path: addUser,
        name: 'addUser',
        builder: (context, state) => const AddUserPage(),
      ),

    ],
  );
}
