part of 'home_cubit.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeData extends HomeState {
  final HomeGeralData geral;
  final HomeVendasData vendas;
  final HomeFaturamentoData faturamento;

  const HomeData({
    required this.geral,
    required this.vendas,
    required this.faturamento,
  });

  @override
  List<Object> get props => [geral, vendas, faturamento];
}

final class HomeError extends HomeState {}

class HomeGeralData extends Equatable {
  final int availableBarrelsCount;
  final int nearExpiryCount;
  final int availableLiters;
  final List<Product> nearExpiryBarrels;
  final List<Product> rentedDispensers;

  const HomeGeralData({
    required this.availableBarrelsCount,
    required this.nearExpiryCount,
    required this.availableLiters,
    required this.nearExpiryBarrels,
    required this.rentedDispensers,
  });

  @override
  List<Object> get props => [
    availableBarrelsCount,
    nearExpiryCount,
    availableLiters,
    nearExpiryBarrels,
    rentedDispensers,
  ];
}

class HomeVendasData extends Equatable {
  final int salesCount;
  final int barrelsSold;
  final int litersSold;
  final List<Sale> recentSales;

  const HomeVendasData({
    required this.salesCount,
    required this.barrelsSold,
    required this.litersSold,
    required this.recentSales,
  });

  @override
  List<Object> get props => [salesCount, barrelsSold, litersSold, recentSales];
}

class HomeFaturamentoData extends Equatable {
  final double revenue;
  final int pendingPaymentsCount;
  final double avgSaleValue;
  final List<Sale> topSales;

  const HomeFaturamentoData({
    required this.revenue,
    required this.pendingPaymentsCount,
    required this.avgSaleValue,
    required this.topSales,
  });

  @override
  List<Object> get props => [
    revenue,
    pendingPaymentsCount,
    avgSaleValue,
    topSales,
  ];
}
