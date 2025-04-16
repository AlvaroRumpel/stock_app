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
        throw FailedToFetch();
      }

      return response.map(Customer.fromMap).toList();
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
