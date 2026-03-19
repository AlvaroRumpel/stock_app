import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/product.dart';
import '../../../../shared/repositories/product_repository.dart';

part 'barrel_detail_state.dart';

class BarrelDetailCubit extends Cubit<BarrelDetailState> {
  final ProductRepository _repo;
  BarrelDetailCubit({required ProductRepository repo})
    : _repo = repo,
      super(BarrelDetailInitial());

  Future<void> load(String productId) async {
    emit(BarrelDetailLoading());
    try {
      final barrel = await _repo.getProductById(productId);
      emit(BarrelDetailLoaded(barrel));
    } catch (e) {
      emit(BarrelDetailError());
    }
  }

  Future<void> deleteProduct(String productId) async {
    emit(BarrelDetailLoading());
    try {
      await _repo.deleteProductById(productId);
      emit(BarrelDetailDeleted());
    } catch (e) {
      emit(BarrelDetailError());
    }
  }
}
