import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/sale.dart';
import '../../../../shared/exception/exceptions.dart';
import '../../../../shared/repositories/sale_repository.dart';

part 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SaleRepository _repo;
  SalesCubit({required SaleRepository repo})
    : _repo = repo,
      super(SalesInitial());

  Future<void> getSales() async {
    try {
      emit(SalesLoading());
      final sales = await _repo.getSales();

      final active =
          sales
              .where((s) => s.status == 'pending' || s.status == 'picked_up')
              .toList();
      final history =
          sales.where((s) => s.status == 'returned').toList();

      emit(SalesData(activeSales: active, historySales: history));
    } catch (e) {
      if (e is EmptyFromFetch) {
        emit(SalesEmpty());
        return;
      }
      emit(SalesError());
    }
  }
}
