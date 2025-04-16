part of 'customer_details_cubit.dart';

sealed class CustomerDetailState extends Equatable {
  const CustomerDetailState();

  @override
  List<Object?> get props => [];
}

final class CustomerDetailInitial extends CustomerDetailState {}

final class CustomerDetailLoading extends CustomerDetailState {}

final class CustomerDetailSuccess extends CustomerDetailState {
  final Customer customers;

  const CustomerDetailSuccess({required this.customers});

  @override
  List<Object?> get props => [customers];
}

final class CustomerDetailError extends CustomerDetailState {}
