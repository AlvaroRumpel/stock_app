part of 'sales_cubit.dart';

sealed class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object> get props => [];
}

final class SalesInitial extends SalesState {}

final class SalesLoading extends SalesState {}

final class SalesData extends SalesState {
  final List<Sale> activeSales;
  final List<Sale> historySales;

  const SalesData({required this.activeSales, required this.historySales});

  @override
  List<Object> get props => [activeSales, historySales];
}

final class SalesError extends SalesState {}

final class SalesEmpty extends SalesState {}
