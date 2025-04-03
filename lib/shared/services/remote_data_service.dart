import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RemoteDataService {
  /// Check if user is logged in
  bool get isLogged;

  /// Get current user's id
  String? get userId;

  /// Get current user
  User? get currentUser;

  /// Get every state change in the user data
  Stream<AuthState> get onAuthStateChanges;

  /// Sign up a new user with email and password
  Future<AuthResponse> signUp(String email, String password);

  /// Sign in with email and password
  Future<AuthResponse> signIn(String email, String password);

  /// Sign out the current user
  Future<void> signOut();

  /// Sign up with phone number
  Future<void> signUpWithPhoneNumber({required String phoneNumber});

  /// Update the current user email
  Future<void> updateEmailUser({required String email});

  /// Sign in with phone number
  Future<void> signInWithPhoneNumber({required String phoneNumber});

  /// Verify a phone OTP
  Future<AuthResponse> verifyPhoneOTP({
    required String phoneNumber,
    required String code,
  });

  /// Fetch data from a specific table with optional filtering
  Future<List<Map<String, dynamic>>> fetchData(
    String table, {
    Map<String, dynamic>? filters,
  });

  /// Insert data into a specific table
  Future<List<Map<String, dynamic>>> insertData(
    String table,
    Map<String, dynamic> data,
  );

  /// Insert many data into a spacific table
  Future<List<Map<String, dynamic>>> insertManyData(
    String table,
    List<Map<String, dynamic>> data,
  );

  /// Update data in a specific table
  Future<void> updateData({
    required String table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
  });

  /// Delete data from a specific table
  Future<void> deleteManyData(String table, List<String> value);

  /// Delete data from a specific table by id
  Future<void> deleteDataById(String table, String id);

  /// Upload a file to a specific bucket
  Future<void> uploadFile({
    required String bucket,
    required String path,
    required File file,
  });

  /// Download a file from a specific bucket
  Future<String> downloadFile(String bucket, String path);

  /// Subscribe to a table for real-time updates
  Stream<List<Map<String, dynamic>>> subscribe(String table);

  /// Subscribe with a callback for easier handling of incoming data
  StreamSubscription<List<Map<String, dynamic>?>>? subscribeWithCallback(
    String table, {
    required void Function(List<Map<String, dynamic>>? data) onData,
  });
}
