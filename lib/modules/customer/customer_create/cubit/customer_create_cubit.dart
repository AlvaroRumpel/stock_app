import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/customer.dart';
import '../../../../shared/repositories/customer_repository.dart';

part 'customer_create_state.dart';

class CustomerCreateCubit extends Cubit<CustomerCreateState> {
  final CustomerRepository _repo;
  CustomerCreateCubit({required CustomerRepository customerRepository})
    : _repo = customerRepository,
      super(CustomerCreateInitial());

  Future<void> createCustomer({
    required String name,
    required String phone,
    String? address,
    required String observation,
  }) async {
    try {
      final customerEdit =
          state is CustomerCreateData
              ? (state as CustomerCreateData).customer
              : null;
      emit(CustomerCreateLoading());
      final customer =
          customerEdit?.copyWith(
            name: name,
            phone: phone,
            address: address,
            observation: observation,
          ) ??
          Customer.newCustomer(
            name: name,
            phone: phone,
            address: address,
            observation: observation,
          );

      final Customer savedCustomer;
      if (customer.id.isNotEmpty) {
        await _repo.updateCustomer(customer);
        savedCustomer = customer;
      } else {
        savedCustomer = await _repo.createCustomer(customer);
      }
      emit(CustomerCreateSuccessCreate(savedCustomer));
    } catch (e) {
      emit(CustomerCreateError());
    }
  }

  Future<void> getCustomer(String customerId) async {
    try {
      emit(CustomerCreateLoading());
      final customer = await _repo.getCustomerById(customerId);
      emit(CustomerCreateData(customer: customer));
    } catch (e) {
      emit(CustomerCreateError());
    }
  }
}
