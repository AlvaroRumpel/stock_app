part of 'sale_create_cubit.dart';

sealed class SaleCreateState extends Equatable {
  const SaleCreateState();

  @override
  List<Object?> get props => [];
}

final class SaleCreateInitial extends SaleCreateState {}

final class SaleCreateLoading extends SaleCreateState {}

final class SaleCreateData extends SaleCreateState {
  final List<Customer> customers;
  final List<Product> products;
  final Customer? selectedCustomer;
  final List<SaleItem> items;
  final bool useCustomerAddress;
  final bool isSubmitting;

  const SaleCreateData({
    required this.customers,
    required this.products,
    this.selectedCustomer,
    required this.items,
    this.useCustomerAddress = false,
    this.isSubmitting = false,
  });

  SaleCreateData copyWith({
    List<Customer>? customers,
    List<Product>? products,
    Customer? selectedCustomer,
    List<SaleItem>? items,
    bool? useCustomerAddress,
    bool? isSubmitting,
  }) {
    return SaleCreateData(
      customers: customers ?? this.customers,
      products: products ?? this.products,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      items: items ?? this.items,
      useCustomerAddress: useCustomerAddress ?? this.useCustomerAddress,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  double get itemsTotal =>
      items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));

  @override
  List<Object?> get props => [
    customers,
    products,
    selectedCustomer,
    items,
    useCustomerAddress,
    isSubmitting,
  ];
}

final class SaleCreateSuccess extends SaleCreateState {}

final class SaleCreateError extends SaleCreateState {}

final class SaleCreateValidationError extends SaleCreateState {
  final String message;
  const SaleCreateValidationError(this.message);

  @override
  List<Object?> get props => [message];
}
