import 'dart:developer';

class StockAppException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  final Object? error;

  StockAppException({required this.message, this.stackTrace, this.error}) {
    log(_exceptionMessage, stackTrace: stackTrace, error: error);
  }

  String get _exceptionMessage =>
      '$runtimeType: $message${error != null ? "\n$error" : ''}';

  @override
  String toString() {
    return message;
  }
}
