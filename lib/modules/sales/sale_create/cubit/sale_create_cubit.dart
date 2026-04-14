import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/customer.dart';
import '../../../../shared/entities/product.dart';
import '../../../../shared/entities/sale.dart';
import '../../../../shared/entities/sale_item.dart';
import '../../../../shared/repositories/customer_repository.dart';
import '../../../../shared/repositories/product_repository.dart';
import '../../../../shared/repositories/sale_repository.dart';

part 'sale_create_state.dart';

class SaleCreateCubit extends Cubit<SaleCreateState> {
  final SaleRepository _saleRepo;
  final CustomerRepository _customerRepo;
  final ProductRepository _productRepo;

  SaleCreateCubit({
    required SaleRepository saleRepo,
    required CustomerRepository customerRepo,
    required ProductRepository productRepo,
  }) : _saleRepo = saleRepo,
       _customerRepo = customerRepo,
       _productRepo = productRepo,
       super(SaleCreateInitial());

  Future<void> loadData() async {
    try {
      emit(SaleCreateLoading());
      List<Customer> customers = [];
      List<Product> products = [];

      try {
        customers = await _customerRepo.getCustomers();
      } catch (_) {}

      try {
        products = await _productRepo.getProducts();
      } catch (_) {}

      // Filter only available products with stock
      products = products.where((p) {
        if (!p.isAvailable) return false;
        if (p.type == ProductTypeEnum.barrel) {
          return (p.qty30l ?? 0) + (p.qty50l ?? 0) > 0;
        }
        return true;
      }).toList();

      emit(
        SaleCreateData(
          customers: customers,
          products: products,
          items: [],
        ),
      );
    } catch (e) {
      emit(SaleCreateError());
    }
  }

  void selectCustomer(Customer customer) {
    if (state is SaleCreateData) {
      emit((state as SaleCreateData).copyWith(selectedCustomer: customer));
    }
  }

  void toggleUseCustomerAddress(bool value) {
    if (state is SaleCreateData) {
      emit((state as SaleCreateData).copyWith(useCustomerAddress: value));
    }
  }

  void addItem(SaleItem item) {
    if (state is SaleCreateData) {
      final data = state as SaleCreateData;
      final newItems = [...data.items, item];
      emit(data.copyWith(items: newItems));
    }
  }

  Future<void> reloadCustomers() async {
    if (state is! SaleCreateData) return;
    final data = state as SaleCreateData;
    try {
      final customers = await _customerRepo.getCustomers();
      emit(data.copyWith(customers: customers));
    } catch (_) {}
  }

  void removeItem(int index) {
    if (state is SaleCreateData) {
      final data = state as SaleCreateData;
      final newItems = List<SaleItem>.from(data.items)..removeAt(index);
      emit(data.copyWith(items: newItems));
    }
  }

  Future<void> createSale({
    required double totalValue,
    required bool isPaid,
    String? address,
    DateTime? returnDate,
    DateTime? pickupDate,
    String? notes,
  }) async {
    if (state is! SaleCreateData) return;
    final data = state as SaleCreateData;

    if (data.selectedCustomer == null) {
      emit(const SaleCreateValidationError('Selecione um cliente'));
      emit(data);
      return;
    }

    if (data.items.isEmpty) {
      emit(const SaleCreateValidationError(
        'Adicione pelo menos um item à venda',
      ));
      emit(data);
      return;
    }

    try {
      emit(data.copyWith(isSubmitting: true));
      final sale = Sale.newSale(
        customerId: data.selectedCustomer!.id,
        totalValue: totalValue,
        isPaid: isPaid,
        address: address,
        returnDate: returnDate,
        pickupDate: pickupDate,
        notes: notes,
      );

      await _saleRepo.createSale(sale, data.items);
      emit(SaleCreateSuccess());
    } catch (e) {
      emit(const SaleCreateValidationError('Erro ao cadastrar venda'));
      emit(data.copyWith(isSubmitting: false));
    }
  }
}
