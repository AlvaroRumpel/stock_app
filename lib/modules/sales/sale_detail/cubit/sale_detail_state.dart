part of 'sale_detail_cubit.dart';

sealed class SaleDetailState extends Equatable {
  const SaleDetailState();

  @override
  List<Object> get props => [];
}

final class SaleDetailInitial extends SaleDetailState {}

final class SaleDetailLoading extends SaleDetailState {}

final class SaleDetailLoaded extends SaleDetailState {
  final Sale sale;

  const SaleDetailLoaded(this.sale);

  @override
  List<Object> get props => [sale];
}

final class SaleDetailError extends SaleDetailState {}

final class SaleDetailDeleted extends SaleDetailState {}
