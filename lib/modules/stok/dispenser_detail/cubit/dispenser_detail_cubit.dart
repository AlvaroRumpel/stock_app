import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/product.dart';
import '../../../../shared/repositories/product_repository.dart';
import '../../../../shared/repositories/sale_repository.dart';

part 'dispenser_detail_state.dart';

class DispenserDetailCubit extends Cubit<DispenserDetailState> {
  final ProductRepository _repo;
  final SaleRepository _saleRepo;
  DispenserDetailCubit({
    required ProductRepository repo,
    required SaleRepository saleRepo,
  }) : _repo = repo,
       _saleRepo = saleRepo,
       super(DispenserDetailInitial());

  Future<void> load(String productId) async {
    emit(DispenserDetailLoading());
    try {
      final dispenser = await _repo.getProductById(productId);
      emit(DispenserDetailLoaded(dispenser));
    } catch (e) {
      emit(const DispenserDetailError());
    }
  }

  Future<void> updateDispenser(Product dispenser) async {
    emit(DispenserDetailLoading());
    try {
      await _repo.updateProduct(dispenser);
      emit(DispenserDetailUpdated());
    } catch (e) {
      emit(const DispenserDetailError());
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(DispenserDetailLoading());
    try {
      final inUse = await _saleRepo.hasActiveSaleForProduct(productId);
      if (inUse) {
        emit(
          const DispenserDetailError(
            message: 'Chopeira em uso em venda ativa, não é possível remover',
          ),
        );
        return;
      }
      await _repo.deleteProductById(productId);
      emit(DispenserDetailDeleted());
    } catch (e) {
      emit(const DispenserDetailError());
    }
  }
}
