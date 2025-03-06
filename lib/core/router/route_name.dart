part of 'app_router.dart';

enum RouteName {
  home(path: '/home', name: 'home');

  final String path;
  final String name;
  const RouteName({required this.path, required this.name});
}
