import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../shared/entities/product.dart';
import '../../../../shared/exception/exceptions.dart';
import '../../../../shared/repositories/product_repository.dart';

part 'stok_state.dart';

class StokCubit extends Cubit<StokState> {
  final ProductRepository _repo;
  StokCubit({required ProductRepository repo})
    : _repo = repo,
      super(StokInitial());

  Future<void> getProducts() async {
    try {
      emit(StokLoading());
      final products = await _repo.getProducts();
      final barrels = <Product>[];
      final dispensers = <Product>[];

      for (final product in products) {
        if (product.type == ProductTypeEnum.barrel) {
          barrels.add(product);
        } else {
          dispensers.add(product);
        }
      }
      emit(StokData(barrelList: barrels, dispenserList: dispensers));
    } catch (e) {
      if (e is EmptyFromFetch) {
        emit(StokEmpty());
        return;
      }
      emit(StokError());
    }
  }
}
