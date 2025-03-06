import 'package:go_router/go_router.dart';

part 'route_name.dart';

class AppRouter {
  final GoRouter router;

  AppRouter()
    : router = GoRouter(initialLocation: RouteName.home.path, routes: []);
}
