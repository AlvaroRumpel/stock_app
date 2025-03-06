import 'exceptions.dart';

class RemoteDataException extends StockAppException {
  RemoteDataException({
    required super.message,
    super.error,
    super.stackTrace,
  });
}

class AuthRemoteException extends RemoteDataException {
  AuthRemoteException({
    super.message = 'Authentication error',
    super.error,
    super.stackTrace,
  });
}

class NotFoundRemoteException extends RemoteDataException {
  NotFoundRemoteException({
    super.message = 'Authentication error',
    super.error,
    super.stackTrace,
  });
}
