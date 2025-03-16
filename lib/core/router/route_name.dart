part of 'app_router.dart';

enum RouteName {
  home(path: '/home', name: 'home'),
  sales(path: '/sales', name: 'sales'),
  customers(path: '/customers', name: 'customers'),
  stok(path: '/stok', name: 'stok');

  final String path;
  final String name;
  const RouteName({required this.path, required this.name});
}
