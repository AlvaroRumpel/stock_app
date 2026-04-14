part of 'customer_create_cubit.dart';

sealed class CustomerCreateState extends Equatable {
  const CustomerCreateState();

  @override
  List<Object?> get props => [];
}

final class CustomerCreateInitial extends CustomerCreateState {}

final class CustomerCreateData extends CustomerCreateState {
  final Customer? customer;

  const CustomerCreateData({this.customer});

  CustomerCreateData copyWith({
    Customer? customer,
  }) {
    return CustomerCreateData(
      customer: customer,
    );
  }

  @override
  List<Object?> get props => [customer];
}

final class CustomerCreateSuccessCreate extends CustomerCreateState {
  final Customer customer;
  const CustomerCreateSuccessCreate(this.customer);

  @override
  List<Object?> get props => [customer];
}

final class CustomerCreateLoading extends CustomerCreateState {}

final class CustomerCreateError extends CustomerCreateState {}
