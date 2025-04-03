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
    required String address,
    required String cityId,
    required String observation,
  }) async {
    try {
      emit(CustomerCreateLoading());
      final customer = Customer.newCustomer(
        name: name,
        phone: phone,
        address: address,
        cityId: cityId.isEmpty ? null : cityId,
        observation: observation,
      );

      await _repo.createCustomer(customer);
      emit(CustomerCreateSuccessCreate());
    } catch (e) {
      emit(CustomerCreateError());
    }
  }
}
