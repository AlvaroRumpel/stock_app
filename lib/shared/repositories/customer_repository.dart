import '../entities/city.dart';
import '../entities/customer.dart';
import '../exception/exceptions.dart';
import '../services/remote_data_service.dart';

class CustomerRepository {
  final RemoteDataService _remote;

  CustomerRepository({required RemoteDataService remote}) : _remote = remote;

  Future<Customer> createCustomer(Customer customer) async {
    try {
      final response = await _remote.insertData(
        Customer.tableName,
        customer.toMap(),
      );

      if (response.isEmpty) {
        throw FailedToInsert();
      }

      return Customer.fromMap(response.first);
    } catch (e, s) {
      throw FailedToInsert(error: e, stackTrace: s);
    }
  }

  Future<List<Customer>> getCustomers() async {
    try {
      final response = await _remote.fetchData(Customer.tableName);

      if (response.isEmpty) {
        throw EmptyFromFetch();
      }

      return response.map(Customer.fromMap).toList();
    } catch (e, s) {
      throw FailedToFetch(error: e, stackTrace: s);
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _remote.updateData(
        table: Customer.tableName,
        data: customer.toMap(),
        column: 'id',
        value: customer.id,
      );
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Failed to update customer with id ${customer.id}',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> deleteCustomerById(String id) async {
    try {
      await _remote.deleteDataById(Customer.tableName, id);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Failed to delete customer with id $id',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<Customer> getCustomerById(String id) async {
    try {
      final response = await _remote.fetchData(
        Customer.tableName,
        filters: {'id': id},
      );

      if (response.isEmpty) {
        throw FailedToFetch();
      }

      return Customer.fromMap(response.first);
    } catch (e, s) {
      throw FailedToFetch(error: e, stackTrace: s);
    }
  }

  Future<List<City>> getCities() async {
    try {
      final response = await _remote.fetchData(
        City.tableName,
        filters: {'uf': 'RS'},
      );

      if (response.isEmpty) {
        throw FailedToFetch();
      }

      return response.map(City.fromMap).toList();
    } catch (e, s) {
      throw FailedToFetch(error: e, stackTrace: s);
    }
  }
}
