import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/product.dart';
import '../../../../shared/repositories/product_repository.dart';
import '../../../../shared/repositories/sale_repository.dart';

part 'barrel_detail_state.dart';

class BarrelDetailCubit extends Cubit<BarrelDetailState> {
  final ProductRepository _repo;
  final SaleRepository _saleRepo;
  BarrelDetailCubit({
    required ProductRepository repo,
    required SaleRepository saleRepo,
  }) : _repo = repo,
       _saleRepo = saleRepo,
       super(BarrelDetailInitial());

  Future<void> load(String productId) async {
    emit(BarrelDetailLoading());
    try {
      final barrel = await _repo.getProductById(productId);
      emit(BarrelDetailLoaded(barrel));
    } catch (e) {
      emit(const BarrelDetailError());
    }
  }

  Future<void> updateBarrel(Product barrel) async {
    emit(BarrelDetailLoading());
    try {
      await _repo.updateProduct(barrel);
      emit(BarrelDetailUpdated());
    } catch (e) {
      emit(const BarrelDetailError());
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(BarrelDetailLoading());
    try {
      await _repo.deleteProductById(productId);
      emit(BarrelDetailDeleted());
    } catch (e) {
      emit(const BarrelDetailError());
    }
  }

  Future<void> clearVolume(String productId, String volume) async {
    emit(BarrelDetailLoading());
    try {
      final inUse = await _saleRepo.hasActiveSaleForProduct(productId);
      if (inUse) {
        emit(
          const BarrelDetailError(
            message: 'Produto em uso em venda ativa, não é possível remover',
          ),
        );
        return;
      }
      await _repo.clearProductVolume(productId, volume);
      emit(BarrelDetailDeleted());
    } catch (e) {
      emit(const BarrelDetailError());
    }
  }
}
