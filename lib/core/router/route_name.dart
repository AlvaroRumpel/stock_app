part of 'app_router.dart';

enum RouteName {
  home(path: '/home', name: 'home'),
  sales(path: '/sales', name: 'sales'),
  createSale(path: '/create-sale', name: 'createSale'),
  saleDetails(path: '/sale-details', name: 'saleDetails'),
  customers(path: '/customers', name: 'customers'),
  createCustomer(path: '/create-customer', name: 'createCustomer'),
  customersDetails(path: '/customer-details', name: 'customersDetails'),
  stok(path: '/stok', name: 'stok'),
  createBarrel(path: '/create-barrel', name: 'createBarrel'),
  detailBarrel(path: '/detail-barrel', name: 'detailBarrel'),
  createDispenser(path: '/create-dispenser', name: 'createDispenser'),
  detailDispenser(path: '/detail-dispenser', name: 'detailDispenser'),
  addSaleItems(path: '/add-sale-items', name: 'addSaleItems'),
  editSale(path: '/edit-sale', name: 'editSale'),
  editBarrel(path: '/edit-barrel', name: 'editBarrel'),
  editDispenser(path: '/edit-dispenser', name: 'editDispenser');

  final String path;
  final String name;
  const RouteName({required this.path, required this.name});
}
