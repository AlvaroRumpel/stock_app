import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/product.dart';
import '../../../../shared/repositories/product_repository.dart';

part 'dispenser_create_state.dart';

class DispenserCreateCubit extends Cubit<DispenserCreateState> {
  final ProductRepository _repo;
  DispenserCreateCubit({required ProductRepository repo})
    : _repo = repo,
      super(BarrelCreateInitial());

  Future<void> createDispenser({
    required String identify,
    String? observation,
  }) async {
    try {
      emit(BarrelCreateLoading());
      final dispenser = Product.newProduct(
        identifyNumber: identify,
        observation: observation,
        type: ProductTypeEnum.dispenser,
      );
      await _repo.createProduct(dispenser);
      emit(BarrelCreateSuccess());
    } catch (e) {
      emit(BarrelCreateError());
    }
  }
}
