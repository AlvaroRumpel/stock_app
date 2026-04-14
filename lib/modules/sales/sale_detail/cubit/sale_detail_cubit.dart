import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/sale.dart';
import '../../../../shared/entities/sale_item.dart';
import '../../../../shared/repositories/sale_repository.dart';

part 'sale_detail_state.dart';

class SaleDetailCubit extends Cubit<SaleDetailState> {
  final SaleRepository _repo;
  SaleDetailCubit({required SaleRepository repo})
    : _repo = repo,
      super(SaleDetailInitial());

  Future<void> loadSale(String saleId) async {
    try {
      emit(SaleDetailLoading());
      final sale = await _repo.getSaleById(saleId);
      emit(SaleDetailLoaded(sale));
    } catch (e) {
      emit(SaleDetailError());
    }
  }

  Future<void> markPickedUp(String saleId) async {
    try {
      emit(SaleDetailLoading());
      final sale = await _repo.getSaleById(saleId);
      await _repo.updateSale(
        sale.copyWith(status: 'picked_up', pickupDate: DateTime.now()),
      );
      await loadSale(saleId);
    } catch (e) {
      emit(SaleDetailError());
    }
  }

  Future<void> markReturned(String saleId) async {
    try {
      emit(SaleDetailLoading());
      final sale = await _repo.getSaleById(saleId);
      await _repo.updateSale(
        sale.copyWith(status: 'returned', returnDate: DateTime.now()),
      );
      await loadSale(saleId);
    } catch (e) {
      emit(SaleDetailError());
    }
  }

  Future<void> markPaid(String saleId) async {
    try {
      emit(SaleDetailLoading());
      final sale = await _repo.getSaleById(saleId);
      await _repo.updateSale(sale.copyWith(isPaid: true));
      await loadSale(saleId);
    } catch (e) {
      emit(SaleDetailError());
    }
  }

  Future<void> updateSaleDetails(
    String saleId, {
    String? address,
    DateTime? pickupDate,
    DateTime? returnDate,
    String? notes,
  }) async {
    try {
      emit(SaleDetailLoading());
      final sale = await _repo.getSaleById(saleId);
      await _repo.updateSale(
        sale.copyWith(
          address: address,
          pickupDate: pickupDate,
          returnDate: returnDate,
          notes: notes,
        ),
      );
      await loadSale(saleId);
    } catch (e) {
      emit(SaleDetailError());
    }
  }

  Future<void> addItemToSale(String saleId, SaleItem item) async {
    try {
      emit(SaleDetailLoading());
      await _repo.addItemToSale(saleId, item);
      await loadSale(saleId);
    } catch (e) {
      emit(SaleDetailError());
    }
  }

  Future<void> finalizeSale(String saleId) async {
    try {
      emit(SaleDetailLoading());
      final sale = await _repo.getSaleById(saleId);
      await _repo.updateSale(
        sale.copyWith(
          status: 'returned',
          returnDate: DateTime.now(),
          isPaid: true,
        ),
      );
      await loadSale(saleId);
    } catch (e) {
      emit(SaleDetailError());
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      emit(SaleDetailLoading());
      await _repo.deleteSaleById(saleId);
      emit(SaleDetailDeleted());
    } catch (e) {
      emit(SaleDetailError());
    }
  }
}
