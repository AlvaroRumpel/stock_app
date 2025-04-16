import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/customer.dart';
import '../../../../shared/repositories/customer_repository.dart';

part 'customer_details_state.dart';

class CustomerDetailCubit extends Cubit<CustomerDetailState> {
  final CustomerRepository _repo;

  CustomerDetailCubit({required CustomerRepository customerRepository})
    : _repo = customerRepository,
      super(CustomerDetailInitial());

  Future<void> fetchCustomer(String id) async {
    try {
      emit(CustomerDetailLoading());

      final customer = await _repo.getCustomerById(id);

      emit(CustomerDetailSuccess(customers: customer));
    } catch (_) {
      emit(CustomerDetailError());
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      emit(CustomerDetailLoading());

      await _repo.deleteCustomerById(id);
    } catch (_) {
      emit(CustomerDetailError());
    }
  }
}
