import 'dart:convert';

import '../utils/string_extensions.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final String? observation;
  final DateTime createAt;
  final DateTime? updateAt;
  final DateTime? deletedAt;

  static String get tableName => 'customer';

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    this.observation,
    required this.createAt,
    this.updateAt,
    this.deletedAt,
  });

  Customer.newCustomer({
    required this.name,
    required this.phone,
    this.address,
    this.observation,
    this.updateAt,
    this.deletedAt,
  }) : id = '',
       createAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'phone': phone.clean().split(' ').join(''),
      'address': address,
      'observation': observation,
      'updated_at': updateAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String?,
      observation:
          map['observation'] != null ? map['observation'] as String : null,
      createAt: DateTime.parse(map['created_at']),
      updateAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) =>
      Customer.fromMap(json.decode(source) as Map<String, dynamic>);

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? observation,
    DateTime? createAt,
    DateTime? updateAt,
    DateTime? deletedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      observation: observation ?? this.observation,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
