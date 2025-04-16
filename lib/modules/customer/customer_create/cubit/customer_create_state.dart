part of 'customer_create_cubit.dart';

sealed class CustomerCreateState extends Equatable {
  const CustomerCreateState();

  @override
  List<Object> get props => [];
}

final class CustomerCreateInitial extends CustomerCreateState {}

final class CustomerCreateData extends CustomerCreateState {
  final List<City> cities;
  final City selectedCity;

  const CustomerCreateData({required this.cities, required this.selectedCity});

  CustomerCreateData copyWith({List<City>? cities, City? selectedCity}) {
    return CustomerCreateData(
      cities: cities ?? this.cities,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }
}

final class CustomerCreateSuccessCreate extends CustomerCreateState {}

final class CustomerCreateLoading extends CustomerCreateState {}

final class CustomerCreateError extends CustomerCreateState {}
