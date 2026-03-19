part of 'app_router.dart';

enum RouteName {
  home(path: '/home', name: 'home'),
  sales(path: '/sales', name: 'sales'),
  customers(path: '/customers', name: 'customers'),
  createCustomer(path: '/create-customer', name: 'createCustomer'),
  customersDetails(path: '/customer-details', name: 'customersDetails'),
  stok(path: '/stok', name: 'stok'),
  createBarrel(path: '/create-barrel', name: 'createBarrel'),
  detailBarrel(path: '/detail-barrel', name: 'detailBarrel'),
  createDispenser(path: '/create-dispenser', name: 'createDispenser'),
  detailDispenser(path: '/detail-barrel', name: 'detailBarrel');

  final String path;
  final String name;
  const RouteName({required this.path, required this.name});
}
