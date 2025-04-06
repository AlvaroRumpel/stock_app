part of 'customer_list_cubit.dart';

sealed class CustomerListState extends Equatable {
  const CustomerListState();

  @override
  List<Object> get props => [];
}

final class CustomerListInitial extends CustomerListState {}

final class CustomerListLoading extends CustomerListState {}

final class CustomerListSuccess extends CustomerListState {}

final class CustomListError extends CustomerListState {}
