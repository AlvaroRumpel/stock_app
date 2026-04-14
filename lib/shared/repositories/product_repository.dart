import '../entities/product.dart';
import '../exception/exceptions.dart';
import '../services/remote_data_service.dart';

class ProductRepository {
  final RemoteDataService _remote;

  ProductRepository({required RemoteDataService remote}) : _remote = remote;

  Future<Product> createProduct(Product product) async {
    try {
      final response = await _remote.insertData(
        Product.tableName,
        product.toMap(),
      );

      if (response.isEmpty) {
        throw FailedToInsert();
      }

      return Product.fromMap(response.first);
    } catch (e, s) {
      throw FailedToInsert(error: e, stackTrace: s);
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await _remote.fetchData(Product.tableName);

      return response.map(Product.fromMap).toList();
    } catch (e, s) {
      throw FailedToFetch(error: e, stackTrace: s);
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _remote.updateData(
        table: Product.tableName,
        data: product.toMap(),
        column: 'id',
        value: product.id,
      );
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Failed to update customer with id ${product.id}',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> clearProductVolume(String productId, String volume) async {
    try {
      final product = await getProductById(productId);

      final bool otherVolumeEmpty;
      final Map<String, dynamic> data;

      if (volume == '30') {
        otherVolumeEmpty = (product.qty50l ?? 0) == 0;
        data = {'qty_30l': 0};
      } else {
        otherVolumeEmpty = (product.qty30l ?? 0) == 0;
        data = {'qty_50l': 0};
      }

      if (otherVolumeEmpty) {
        await deleteProductById(productId);
      } else {
        await _remote.updateData(
          table: Product.tableName,
          data: data,
          column: 'id',
          value: productId,
        );
      }
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Failed to clear volume $volume for product $productId',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> deleteProductById(String id) async {
    try {
      await _remote.deleteDataById(Product.tableName, id);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Failed to delete customer with id $id',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _remote.fetchData(
        Product.tableName,
        filters: {'id': id},
      );

      if (response.isEmpty) {
        throw FailedToFetch();
      }

      return Product.fromMap(response.first);
    } catch (e, s) {
      throw FailedToFetch(error: e, stackTrace: s);
    }
  }
}
