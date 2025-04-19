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

class FailedToInsert extends StockAppException {
  FailedToInsert({String? message, super.error, super.stackTrace})
    : super(message: message ?? 'Erro ao inserir os dados');
}

class FailedToFetch extends StockAppException {
  FailedToFetch({String? message, super.error, super.stackTrace})
    : super(message: message ?? 'Erro ao buscar os dados');
}

class EmptyFromFetch extends StockAppException {
  EmptyFromFetch({String? message, super.error, super.stackTrace})
    : super(message: message ?? 'Erro ao buscar os dados');
}
