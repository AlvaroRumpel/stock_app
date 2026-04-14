import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/entities/product.dart';
import '../../../shared/entities/sale.dart';
import '../../../shared/entities/sale_item.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/repositories/sale_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final SaleRepository _saleRepo;
  final ProductRepository _productRepo;

  HomeCubit({
    required SaleRepository saleRepo,
    required ProductRepository productRepo,
  }) : _saleRepo = saleRepo,
       _productRepo = productRepo,
       super(HomeInitial());

  Future<void> loadDashboard() async {
    try {
      emit(HomeLoading());

      List<Sale> sales = [];
      List<Product> products = [];

      try {
        sales = await _saleRepo.getSales();
      } catch (_) {}

      try {
        products = await _productRepo.getProducts();
      } catch (_) {}

      final now = DateTime.now();
      final barrels =
          products.where((p) => p.type == ProductTypeEnum.barrel).toList();
      final dispensers =
          products.where((p) => p.type == ProductTypeEnum.dispenser).toList();

      // --- Geral ---
      final availableBarrels =
          barrels
              .where((b) => (b.qty30l ?? 0) + (b.qty50l ?? 0) > 0)
              .toList();
      final availableBarrelsCount = availableBarrels.length;

      final availableLiters = barrels.fold<int>(
        0,
        (sum, b) => sum + (b.qty30l ?? 0) * 30 + (b.qty50l ?? 0) * 50,
      );

      final nearExpiryBarrels =
          barrels.where((b) {
            if (b.expirationDate == null) return false;
            final days = b.expirationDate!.difference(now).inDays;
            return days >= 0 && days <= 7;
          }).toList();

      final rentedDispensers =
          dispensers.where((d) => !d.isAvailable).toList();

      // --- Vendas ---
      final allItems =
          sales.expand((s) => s.items ?? <SaleItem>[]).toList();

      final barrelItems =
          allItems
              .where(
                (i) =>
                    i.volume == '30' ||
                    i.volume == '50',
              )
              .toList();

      final barrelsSold = barrelItems.fold<int>(
        0,
        (sum, i) => sum + i.quantity,
      );

      final litersSold = barrelItems.fold<int>(
        0,
        (sum, i) =>
            sum + i.quantity * (int.tryParse(i.volume) ?? 0),
      );

      final sortedByDate = List<Sale>.from(sales)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentSales = sortedByDate.take(5).toList();

      // --- Faturamento ---
      final paidSales = sales.where((s) => s.isPaid).toList();
      final revenue = paidSales.fold<double>(
        0,
        (sum, s) => sum + s.totalValue,
      );
      final pendingPaymentsCount = sales.where((s) => !s.isPaid).length;
      final avgSaleValue =
          sales.isEmpty ? 0.0 : sales.fold<double>(
            0,
            (sum, s) => sum + s.totalValue,
          ) /
          sales.length;

      final sortedByValue = List<Sale>.from(sales)
        ..sort((a, b) => b.totalValue.compareTo(a.totalValue));
      final topSales = sortedByValue.take(5).toList();

      emit(
        HomeData(
          geral: HomeGeralData(
            availableBarrelsCount: availableBarrelsCount,
            nearExpiryCount: nearExpiryBarrels.length,
            availableLiters: availableLiters,
            nearExpiryBarrels: nearExpiryBarrels,
            rentedDispensers: rentedDispensers,
          ),
          vendas: HomeVendasData(
            salesCount: sales.length,
            barrelsSold: barrelsSold,
            litersSold: litersSold,
            recentSales: recentSales,
          ),
          faturamento: HomeFaturamentoData(
            revenue: revenue,
            pendingPaymentsCount: pendingPaymentsCount,
            avgSaleValue: avgSaleValue,
            topSales: topSales,
          ),
        ),
      );
    } catch (e) {
      emit(HomeError());
    }
  }
}
