import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';

class RemoteDataSettings {
  /// Initialize the supabase settings
  static Future<void> load() async {
    await Supabase.initialize(
      url: AppConfig.remoteDataUrl,
      anonKey: AppConfig.key,
    );
  }
}
