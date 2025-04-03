part of 'customer_create_cubit.dart';

sealed class CustomerCreateState extends Equatable {
  const CustomerCreateState();

  @override
  List<Object> get props => [];
}

final class CustomerCreateInitial extends CustomerCreateState {}

final class CustomerCreateSuccessCreate extends CustomerCreateState {}

final class CustomerCreateLoading extends CustomerCreateState {}

final class CustomerCreateError extends CustomerCreateState {}
