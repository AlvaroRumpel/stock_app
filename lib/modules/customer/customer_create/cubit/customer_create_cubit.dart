import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/city.dart';
import '../../../../shared/entities/customer.dart';
import '../../../../shared/repositories/customer_repository.dart';

part 'customer_create_state.dart';

class CustomerCreateCubit extends Cubit<CustomerCreateState> {
  final CustomerRepository _repo;
  CustomerCreateCubit({required CustomerRepository customerRepository})
    : _repo = customerRepository,
      super(CustomerCreateInitial()) {
    _getCities();
  }

  Future<void> _getCities() async {
    try {
      emit(CustomerCreateLoading());
      final cities = await _repo.getCities();
      final selectedCity = cities.firstWhere((e) => e.code == 4319802);
      emit(CustomerCreateData(cities: cities, selectedCity: selectedCity));
    } catch (e) {
      emit(CustomerCreateError());
    }
  }

  void changeCity(City city) {
    emit((state as CustomerCreateData).copyWith(selectedCity: city));
  }

  Future<void> createCustomer({
    required String name,
    required String phone,
    required String address,
    required String observation,
  }) async {
    try {
      final city =
          state is CustomerCreateData
              ? (state as CustomerCreateData).selectedCity
              : null;
      emit(CustomerCreateLoading());
      final customer = Customer.newCustomer(
        name: name,
        phone: phone,
        address: address,
        cityId: city?.id,
        observation: observation,
      );

      await _repo.createCustomer(customer);
      emit(CustomerCreateSuccessCreate());
    } catch (e) {
      emit(CustomerCreateError());
    }
  }
}
