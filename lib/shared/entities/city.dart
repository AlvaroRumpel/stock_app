import 'dart:convert';

class City {
  final String id;
  final String cityName;
  final String stateName;
  final String uf;
  final int code;

  static String get tableName => 'city';

  City({
    required this.id,
    required this.cityName,
    required this.stateName,
    required this.uf,
    required this.code,
  });

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] as String,
      cityName: map['city_name'] as String,
      stateName: map['state_name'] as String,
      uf: map['uf'] as String,
      code: map['code'] as int,
    );
  }

  factory City.fromJson(String source) =>
      City.fromMap(json.decode(source) as Map<String, dynamic>);
}
