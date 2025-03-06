import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../exception/exceptions.dart';
import 'remote_data_service.dart';

class RemoteDataServiceImpl implements RemoteDataService {
  final _client = Supabase.instance.client;

  // AUTHENTICATION SECTION
  @override
  bool get isLogged => _client.auth.currentSession?.accessToken != null;

  @override
  String? get userId => _client.auth.currentSession?.user.id;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e, s) {
      throw AuthRemoteException(message: e.message, error: e, stackTrace: s);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Authentication on create user',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e, s) {
      throw AuthRemoteException(message: e.message, error: e, stackTrace: s);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Authentication failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e, s) {
      throw AuthRemoteException(message: e.message, error: e, stackTrace: s);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Authentication on logout',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> signUpWithPhoneNumber({required String phoneNumber}) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: true,
      );
    } on AuthException catch (e, s) {
      throw AuthRemoteException(message: e.message, error: e, stackTrace: s);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Authentication on create user',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> updateEmailUser({required String email}) async {
    try {
      await _client.auth.updateUser(UserAttributes(email: email));
    } on AuthException catch (e, s) {
      throw AuthRemoteException(message: e.message, error: e, stackTrace: s);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Authentication failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
  }) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phoneNumber,
        shouldCreateUser: false,
      );
    } on AuthException catch (e, s) {
      throw AuthRemoteException(message: e.message, error: e, stackTrace: s);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Authentication failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<AuthResponse> verifyPhoneOTP({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final result = await _client.auth.verifyOTP(
        phone: phoneNumber,
        token: code,
        type: OtpType.sms,
      );

      return result;
    } on AuthException catch (e, s) {
      throw AuthRemoteException(message: e.message, error: e, stackTrace: s);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Authentication failed',
        error: e,
        stackTrace: s,
      );
    }
  }
  // DATABASE SECTION

  @override
  Future<List<Map<String, dynamic>>?> fetchData(
    String table, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      var query = _client.from(table).select();

      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      final response = await query;
      return response as List<Map<String, dynamic>>?;
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Error on fetch data in $table',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> insertData(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select();
      if (response.isEmpty) {
        return [];
      }

      return response;
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Error on insert data on $table',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> insertManyData(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select();
      if (response.isEmpty) {
        return [];
      }

      return response;
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Error on insert data on $table',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> updateData({
    required String table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
  }) async {
    try {
      await _client.from(table).update(data).eq(column, value);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Error on update data on $table',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> deleteManyData(String table, List<String> value) async {
    try {
      await _client.from(table).delete().inFilter('id', value);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Error on delete data in $table',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> deleteDataById(String table, String id) async {
    try {
      final result = await _client.from(table).delete().match(
        {'id': id},
      ).select();

      if (kDebugMode) {
        print(result);
      }
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Error on delete data by id: $id in $table',
        error: e,
        stackTrace: s,
      );
    }
  }

  // STORAGE SECTION
  @override
  Future<void> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    try {
      await _client.storage.from(bucket).upload(path, file);
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Error to save the ${file.path} from $path in $bucket',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<String> downloadFile(String bucket, String path) async {
    try {
      final response = await _client.storage
          .from(bucket)
          .createSignedUrl(path, 60); // expires in 60 seconds
      return response;
    } catch (e, s) {
      throw RemoteDataException(
        message: 'Error to download a file from $path from $bucket',
        error: e,
        stackTrace: s,
      );
    }
  }

  // REAL-TIME SECTION
  @override
  Stream<List<Map<String, dynamic>>> subscribe(String table) {
    return _client
        .from(table)
        .stream(primaryKey: ['*']).asyncMap((event) => event);
  }

  @override
  StreamSubscription<List<Map<String, dynamic>?>>? subscribeWithCallback(
    String table, {
    required void Function(List<Map<String, dynamic>>? data) onData,
  }) {
    final subscription = subscribe(table).listen(onData);
    return subscription;
  }
}
