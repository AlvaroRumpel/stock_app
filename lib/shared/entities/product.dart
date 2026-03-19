import 'dart:convert';

class Product {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? batchNumber;
  final VolumeEnum? volume;
  final int? availableQuantity;
  final DateTime? expirationDate;
  final double? costPrice;
  final double? salePrice;
  final int? identifyNumber;
  final String? observation;
  final ProductTypeEnum type;

  static String get tableName => 'product';

  Product({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.batchNumber,
    this.volume,
    this.availableQuantity,
    this.expirationDate,
    this.costPrice,
    this.salePrice,
    this.identifyNumber,
    this.observation,
    required this.type,
  });

  Product.newProduct({
    this.batchNumber,
    this.volume,
    this.availableQuantity,
    this.expirationDate,
    this.costPrice,
    this.salePrice,
    this.identifyNumber,
    this.observation,
    required this.type,
    this.updatedAt,
    this.deletedAt,
  }) : id = '',
       createdAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'batch_number': batchNumber,
      'volume': volume?.volume.toString(),
      'available_quantity': availableQuantity,
      'expiration_date': expirationDate?.toIso8601String(),
      'cost_price': costPrice,
      'sale_price': salePrice,
      'identify_number': identifyNumber,
      'observation': observation,
      'type': type.toString(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
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
      volume:
          map['volume'] != null ? VolumeEnum.fromString(map['volume']) : null,
      availableQuantity: map['available_quantity'],
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
      identifyNumber: map['identify_number'],
      observation: map['observation'],
      type: ProductTypeEnum.fromString(map['type']),
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
    VolumeEnum? volume,
    int? availableQuantity,
    DateTime? expirationDate,
    double? costPrice,
    double? salePrice,
    int? identifyNumber,
    String? observation,
    ProductTypeEnum? type,
  }) {
    return Product(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      batchNumber: batchNumber ?? this.batchNumber,
      volume: volume ?? this.volume,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      expirationDate: expirationDate ?? this.expirationDate,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      identifyNumber: identifyNumber ?? this.identifyNumber,
      observation: observation ?? this.observation,
      type: type ?? this.type,
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
