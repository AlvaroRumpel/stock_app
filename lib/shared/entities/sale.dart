import 'dart:convert';

import 'customer.dart';
import 'sale_item.dart';

class Sale {
  final String id;
  final String? customerId;
  final double totalValue;
  final double? pricePerLiter;
  final DateTime? pickupDate;
  final DateTime? returnDate;
  final bool isPaid;
  final String status;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  // Nested for display
  final Customer? customer;
  final List<SaleItem>? items;

  static String get tableName => 'sale';

  Sale({
    required this.id,
    this.customerId,
    required this.totalValue,
    this.pricePerLiter,
    this.pickupDate,
    this.returnDate,
    required this.isPaid,
    required this.status,
    this.address,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.customer,
    this.items,
  });

  Sale.newSale({
    this.customerId,
    this.totalValue = 0,
    this.pricePerLiter,
    this.pickupDate,
    this.returnDate,
    this.isPaid = false,
    this.status = 'pending',
    this.address,
    this.notes,
    this.updatedAt,
    this.deletedAt,
    this.customer,
    this.items,
  }) : id = '',
       createdAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'total_value': totalValue,
      'price_per_liter': pricePerLiter,
      'pickup_date': pickupDate?.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'is_paid': isPaid,
      'status': status,
      'address': address,
      'notes': notes,
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as String,
      customerId: map['customer_id'] as String?,
      totalValue: double.tryParse(map['total_value'].toString()) ?? 0,
      pricePerLiter:
          map['price_per_liter'] != null
              ? double.tryParse(map['price_per_liter'].toString())
              : null,
      pickupDate:
          map['pickup_date'] != null
              ? DateTime.parse(map['pickup_date'])
              : null,
      returnDate:
          map['return_date'] != null
              ? DateTime.parse(map['return_date'])
              : null,
      isPaid: map['is_paid'] as bool? ?? false,
      status: map['status'] as String? ?? 'pending',
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Sale.fromJson(String source) =>
      Sale.fromMap(json.decode(source) as Map<String, dynamic>);

  Sale copyWith({
    String? id,
    String? customerId,
    double? totalValue,
    double? pricePerLiter,
    DateTime? pickupDate,
    DateTime? returnDate,
    bool? isPaid,
    String? status,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Customer? customer,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      totalValue: totalValue ?? this.totalValue,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      customer: customer ?? this.customer,
      items: items ?? this.items,
    );
  }

  String get statusLocalized => switch (status) {
    'pending' => 'Pendente',
    'picked_up' => 'Retirado',
    'returned' => 'Devolvido',
    _ => status,
  };
}
