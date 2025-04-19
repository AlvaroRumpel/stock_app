import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/customer.dart';
import '../../../../shared/exception/exceptions.dart';
import '../../../../shared/repositories/customer_repository.dart';

part 'customer_list_state.dart';

class CustomerListCubit extends Cubit<CustomerListState> {
  final CustomerRepository _repo;

  CustomerListCubit({required CustomerRepository customerRepository})
    : _repo = customerRepository,
      super(CustomerListInitial());

  Future<void> fetchAllCustomers() async {
    try {
      emit(CustomerListLoading());

      final customers = await _repo.getCustomers();

      emit(CustomerListSuccess(customers: customers));
    } catch (e) {
      if (e is EmptyFromFetch) {
        emit(CustomerListEmpty());
        return;
      }
      emit(CustomerListError());
    }
  }
}
