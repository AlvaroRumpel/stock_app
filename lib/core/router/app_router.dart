import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../modules/customer/customer_create/customer_create_page.dart';
import '../../modules/customer/customers_list/customers_page.dart';
import '../../modules/home/home_page.dart';
import '../../modules/sales/sales_page.dart';
import '../../modules/stok/stok_page.dart';
import '../../shared/widgets/scaffold_with_navigation_bar.dart';

part 'route_name.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final GoRouter router;

  AppRouter()
    : router = GoRouter(
        initialLocation: RouteName.home.path,
        navigatorKey: _rootNavigatorKey,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ScaffoldWithNavigationBar(
                navigationShell: navigationShell,
              );
            },
            branches: [
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: RouteName.home.path,
                    name: RouteName.home.name,
                    builder: (context, state) => const HomePage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: RouteName.sales.path,
                    name: RouteName.sales.name,
                    builder: (context, state) => const SalesPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: RouteName.stok.path,
                    name: RouteName.stok.name,
                    builder: (context, state) => const StokPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: <RouteBase>[
                  GoRoute(
                    path: RouteName.customers.path,
                    name: RouteName.customers.name,
                    builder: (context, state) => const CustomersPage(),
                    routes: [
                      GoRoute(
                        path: RouteName.createCustomer.path,
                        name: RouteName.createCustomer.name,
                        parentNavigatorKey: _sectionNavigatorKey,
                        builder: (context, state) => const CustomerCreatePage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}
