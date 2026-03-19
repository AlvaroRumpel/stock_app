import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/product.dart';
import '../../../../shared/repositories/product_repository.dart';
import '../../../../shared/utils/string_extensions.dart';

part 'barrel_create_state.dart';

class BarrelCreateCubit extends Cubit<BarrelCreateState> {
  final ProductRepository _repo;
  BarrelCreateCubit({required ProductRepository repo})
    : _repo = repo,
      super(BarrelCreateInitial());

  Future<void> createBarrel({
    required String batchNumber,
    required VolumeEnum volume,
    required String quantity,
    required DateTime expirationDate,
    required String costPrice,
    required String sellPrice,
    String? observation,
  }) async {
    try {
      emit(BarrelCreateLoading());
      final barrel = Product.newProduct(
        batchNumber: batchNumber,
        volume: volume,
        availableQuantity: int.parse(quantity),
        expirationDate: expirationDate,
        costPrice: double.parse(costPrice.toCurrencyFixed),
        salePrice: double.parse(sellPrice.toCurrencyFixed),
        observation: observation,
        type: ProductTypeEnum.barrel,
      );
      await _repo.createProduct(barrel);
      emit(BarrelCreateSuccess());
    } catch (e) {
      emit(BarrelCreateError());
    }
  }
}
