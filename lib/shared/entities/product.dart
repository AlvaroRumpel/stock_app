import 'dart:convert';

class Product {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? batchNumber;
  final int? qty30l;
  final int? qty50l;
  final DateTime? expirationDate;
  final double? costPrice;
  final double? salePrice;
  final String? identifyNumber;
  final String? observation;
  final ProductTypeEnum type;
  final bool isAvailable;
  final DateTime? returnDate;

  static String get tableName => 'product';

  Product({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.batchNumber,
    this.qty30l,
    this.qty50l,
    this.expirationDate,
    this.costPrice,
    this.salePrice,
    this.identifyNumber,
    this.observation,
    required this.type,
    this.isAvailable = true,
    this.returnDate,
  });

  Product.newProduct({
    this.batchNumber,
    this.qty30l,
    this.qty50l,
    this.expirationDate,
    this.costPrice,
    this.salePrice,
    this.identifyNumber,
    this.observation,
    required this.type,
    this.updatedAt,
    this.deletedAt,
    this.isAvailable = true,
    this.returnDate,
  }) : id = '',
       createdAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'batch_number': batchNumber,
      'qty_30l': qty30l,
      'qty_50l': qty50l,
      'expiration_date': expirationDate?.toIso8601String(),
      'cost_price': costPrice,
      'sale_price': salePrice,
      'identify_number': identifyNumber,
      'observation': observation,
      'type': type.toString(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_available': isAvailable,
      'return_date': returnDate?.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      batchNumber: map['batch_number'],
      qty30l: map['qty_30l'],
      qty50l: map['qty_50l'],
      expirationDate:
          map['expiration_date'] != null
              ? DateTime.parse(map['expiration_date'])
              : null,
      costPrice:
          map['cost_price'] != null
              ? double.tryParse(map['cost_price'].toString())
              : null,
      salePrice:
          map['sale_price'] != null
              ? double.tryParse(map['sale_price'].toString())
              : null,
      identifyNumber: map['identify_number']?.toString(),
      observation: map['observation'],
      type: ProductTypeEnum.fromString(map['type']),
      isAvailable: map['is_available'] as bool? ?? true,
      returnDate:
          map['return_date'] != null
              ? DateTime.parse(map['return_date'])
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));

  Product copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? batchNumber,
    int? qty30l,
    int? qty50l,
    DateTime? expirationDate,
    double? costPrice,
    double? salePrice,
    String? identifyNumber,
    String? observation,
    ProductTypeEnum? type,
    bool? isAvailable,
    DateTime? returnDate,
  }) {
    return Product(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      batchNumber: batchNumber ?? this.batchNumber,
      qty30l: qty30l ?? this.qty30l,
      qty50l: qty50l ?? this.qty50l,
      expirationDate: expirationDate ?? this.expirationDate,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      identifyNumber: identifyNumber ?? this.identifyNumber,
      observation: observation ?? this.observation,
      type: type ?? this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      returnDate: returnDate ?? this.returnDate,
    );
  }
}

enum VolumeEnum {
  v30(30),
  v50(50);

  final int volume;
  const VolumeEnum(this.volume);

  static VolumeEnum fromString(String value) => switch (value) {
    '30' => VolumeEnum.v30,
    '50' => VolumeEnum.v50,
    _ => VolumeEnum.v30,
  };
}

enum ProductTypeEnum {
  barrel,
  dispenser;

  static ProductTypeEnum fromString(String value) => switch (value) {
    'barrel' => ProductTypeEnum.barrel,
    'dispenser' => ProductTypeEnum.dispenser,
    _ => ProductTypeEnum.dispenser,
  };

  @override
  String toString() => switch (this) {
    ProductTypeEnum.barrel => 'barrel',
    ProductTypeEnum.dispenser => 'dispenser',
  };

  String toStringLocalized() => switch (this) {
    ProductTypeEnum.barrel => 'Barril',
    ProductTypeEnum.dispenser => 'Chopeira',
  };
}
