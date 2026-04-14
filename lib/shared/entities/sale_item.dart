import 'dart:convert';

import 'product.dart';

class SaleItem {
  final String id;
  final String saleId;
  final String? productId;
  final int quantity;
  final String volume;
  final double unitPrice;
  final DateTime createdAt;

  // Nested for display
  final Product? product;

  static String get tableName => 'sale_item';

  SaleItem({
    required this.id,
    required this.saleId,
    this.productId,
    required this.quantity,
    required this.volume,
    required this.unitPrice,
    required this.createdAt,
    this.product,
  });

  SaleItem.newItem({
    this.saleId = '',
    this.productId,
    required this.quantity,
    required this.volume,
    required this.unitPrice,
    this.product,
  }) : id = '',
       createdAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'volume': volume,
      'unit_price': unitPrice,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'] as String,
      saleId: map['sale_id'] as String,
      productId: map['product_id'] as String?,
      quantity: map['quantity'] as int,
      volume: map['volume'] as String,
      unitPrice: double.tryParse(map['unit_price'].toString()) ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SaleItem.fromJson(String source) =>
      SaleItem.fromMap(json.decode(source) as Map<String, dynamic>);

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    int? quantity,
    String? volume,
    double? unitPrice,
    DateTime? createdAt,
    Product? product,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      volume: volume ?? this.volume,
      unitPrice: unitPrice ?? this.unitPrice,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product,
    );
  }

  String get volumeLabel => '${volume}L';
}
