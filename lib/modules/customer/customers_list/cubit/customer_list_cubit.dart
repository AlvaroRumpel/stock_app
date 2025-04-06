import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/customer.dart';
import '../../../../shared/repositories/customer_repository.dart';

part 'customer_list_state.dart';

class CustomerListCubit extends Cubit<CustomerListState> {
  final CustomerRepository _repo;
  List<Customer> customers = [];

  CustomerListCubit({required CustomerRepository customerRepository})
    : _repo = customerRepository,
      super(CustomerListInitial());

  Future<void> fetchAllCustomers() async {
    try {
      emit(CustomerListLoading());

      customers = await _repo.getCustomers();

      emit(CustomerListSuccess());
    } catch (e) {
      emit(CustomListError());
    }
  }
}
