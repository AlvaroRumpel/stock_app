import '../entities/customer.dart';
import '../entities/product.dart';
import '../entities/sale.dart';
import '../entities/sale_item.dart';
import '../exception/exceptions.dart';
import '../services/remote_data_service.dart';

class SaleRepository {
  final RemoteDataService _remote;

  SaleRepository({required RemoteDataService remote}) : _remote = remote;

  Future<Sale> createSale(Sale sale, List<SaleItem> items) async {
    try {
      final response = await _remote.insertData(
        Sale.tableName,
        sale.toMap(),
      );

      if (response.isEmpty) {
        throw FailedToInsert();
      }

      final createdSale = Sale.fromMap(response.first);

      // Insert sale items
      if (items.isNotEmpty) {
        final itemMaps =
            items
                .map(
                  (item) => item.copyWith(saleId: createdSale.id).toMap(),
                )
                .toList();
        await _remote.insertManyData(SaleItem.tableName, itemMaps);
      }

      // Decrement product stock and mark dispensers unavailable
      for (final item in items) {
        if (item.productId != null) {
          await _decrementStock(
            item.productId!,
            item.quantity,
            item.volume,
          );
        }
      }

      // Mark dispensers as unavailable
      for (final item in items) {
        if (item.productId != null && item.volume == 'dispenser') {
          await _remote.updateData(
            table: Product.tableName,
            data: {
              'is_available': false,
              'return_date': sale.returnDate?.toIso8601String(),
            },
            column: 'id',
            value: item.productId!,
          );
        }
      }

      return createdSale;
    } catch (e, s) {
      throw FailedToInsert(error: e, stackTrace: s);
    }
  }

  Future<void> _decrementStock(
    String productId,
    int quantity,
    String volume,
  ) async {
    final response = await _remote.fetchData(
      Product.tableName,
      filters: {'id': productId},
    );
    if (response.isEmpty) return;

    final product = Product.fromMap(response.first);
    final Map<String, dynamic> updateData;

    if (volume == '30') {
      final newQty = (product.qty30l ?? 0) - quantity;
      updateData = {'qty_30l': newQty < 0 ? 0 : newQty};
    } else {
      final newQty = (product.qty50l ?? 0) - quantity;
      updateData = {'qty_50l': newQty < 0 ? 0 : newQty};
    }

    await _remote.updateData(
      table: Product.tableName,
      data: updateData,
      column: 'id',
      value: productId,
    );
  }

  Future<List<Sale>> getSales() async {
    try {
      final response = await _remote.fetchData(Sale.tableName);

      final sales = response.map(Sale.fromMap).toList();

      // Enrich with customer data and items
      final enrichedSales = <Sale>[];
      for (final sale in sales) {
        Customer? customer;
        if (sale.customerId != null) {
          try {
            final customerResponse = await _remote.fetchData(
              Customer.tableName,
              filters: {'id': sale.customerId},
            );
            if (customerResponse.isNotEmpty) {
              customer = Customer.fromMap(customerResponse.first);
            }
          } catch (_) {}
        }

        List<SaleItem> items = [];
        try {
          final itemsResponse = await _remote.fetchData(
            SaleItem.tableName,
            filters: {'sale_id': sale.id},
          );
          items = itemsResponse.map(SaleItem.fromMap).toList();
        } catch (_) {}

        enrichedSales.add(sale.copyWith(customer: customer, items: items));
      }

      return enrichedSales;
    } catch (e, s) {
      throw FailedToFetch(error: e, stackTrace: s);
    }
  }

  Future<Sale> getSaleById(String id) async {
    try {
      final response = await _remote.fetchData(
        Sale.tableName,
        filters: {'id': id},
      );

      if (response.isEmpty) {
        throw FailedToFetch();
      }

      var sale = Sale.fromMap(response.first);

      // Fetch customer
      if (sale.customerId != null) {
        try {
          final customerResponse = await _remote.fetchData(
            Customer.tableName,
            filters: {'id': sale.customerId},
          );
          if (customerResponse.isNotEmpty) {
            sale = sale.copyWith(
              customer: Customer.fromMap(customerResponse.first),
            );
          }
        } catch (_) {}
      }

      // Fetch items
      final itemsResponse = await _remote.fetchData(
        SaleItem.tableName,
        filters: {'sale_id': id},
      );
      final items = itemsResponse.map(SaleItem.fromMap).toList();

      // Enrich items with product data
      final enrichedItems = <SaleItem>[];
      for (final item in items) {
        Product? product;
        if (item.productId != null) {
          try {
            final productResponse = await _remote.fetchData(
              Product.tableName,
              filters: {'id': item.productId},
              getDeleted: true,
            );
            if (productResponse.isNotEmpty) {
              product = Product.fromMap(productResponse.first);
            }
          } catch (_) {}
        }
        enrichedItems.add(item.copyWith(product: product));
      }

      return sale.copyWith(items: enrichedItems);
    } catch (e, s) {
      throw FailedToFetch(error: e, stackTrace: s);
    }
  }

  Future<void> updateSale(Sale sale) async {
    try {
      await _remote.updateData(
        table: Sale.tableName,
        data: sale.toMap(),
        column: 'id',
        value: sale.id,
      );

      // When sale is returned, restore dispenser availability
      if (sale.status == 'returned') {
        try {
          final itemsResponse = await _remote.fetchData(
            SaleItem.tableName,
            filters: {'sale_id': sale.id},
          );
          final items = itemsResponse.map(SaleItem.fromMap).toList();
          for (final item in items) {
            if (item.productId != null && item.volume == 'dispenser') {
              await _remote.updateData(
                table: Product.tableName,
                data: {'is_available': true, 'return_date': null},
                column: 'id',
                value: item.productId!,
              );
            }
          }
        } catch (_) {}
      }
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Failed to update sale with id ${sale.id}',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<bool> hasActiveSaleForProduct(String productId) async {
    try {
      final itemsResponse = await _remote.fetchData(
        SaleItem.tableName,
        filters: {'product_id': productId},
      );
      if (itemsResponse.isEmpty) return false;

      for (final itemMap in itemsResponse) {
        final saleId = itemMap['sale_id'] as String?;
        if (saleId == null) continue;
        final saleResponse = await _remote.fetchData(
          Sale.tableName,
          filters: {'id': saleId},
        );
        if (saleResponse.isEmpty) continue;
        final status = saleResponse.first['status'] as String? ?? '';
        if (status != 'returned') return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> addItemToSale(String saleId, SaleItem item) async {
    try {
      await _remote.insertData(
        SaleItem.tableName,
        item.copyWith(saleId: saleId).toMap(),
      );
      if (item.productId != null) {
        await _decrementStock(item.productId!, item.quantity, item.volume);
        if (item.volume == 'dispenser') {
          await _remote.updateData(
            table: Product.tableName,
            data: {'is_available': false},
            column: 'id',
            value: item.productId!,
          );
        }
      }
    } catch (e, s) {
      throw FailedToInsert(error: e, stackTrace: s);
    }
  }

  Future<void> deleteSaleById(String id) async {
    try {
      await _remote.deleteDataById(Sale.tableName, id);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Failed to delete sale with id $id',
        error: e,
        stackTrace: s,
      );
    }
  }
}
