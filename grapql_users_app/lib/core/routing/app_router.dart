import 'package:go_router/go_router.dart';
import '../../features/users/presentation/screens/home_screen.dart';

class AppRouter {
  static const String home = '/';


  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

    ],
  );
}
