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

      if (response.isEmpty) {
        throw EmptyFromFetch();
      }

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
