class AppConfig {
  /// URL for access the remote data service
  static const remoteDataUrl = String.fromEnvironment('REMOTE_URL');

  /// Key for get the access to the remote data service
  static const key = String.fromEnvironment('REMOTE_KEY');
}
