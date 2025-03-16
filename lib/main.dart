import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/services/remote_data_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR', null);
  await RemoteDataSettings.load();

  final appRouter = AppRouter();

  runApp(App(router: appRouter));
}

class App extends StatelessWidget {
  final AppRouter _appRouter;
  const App({super.key, required AppRouter router}) : _appRouter = router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouter.router.routerDelegate,
      routeInformationParser: _appRouter.router.routeInformationParser,
      routeInformationProvider: _appRouter.router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
    );
  }
}
