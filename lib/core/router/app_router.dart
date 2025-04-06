import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../modules/customer/customer_create/cubit/customer_create_cubit.dart';
import '../../modules/customer/customer_create/customer_create_page.dart';
import '../../modules/customer/customers_list/cubit/customer_list_cubit.dart';
import '../../modules/customer/customers_list/customers_page.dart';
import '../../modules/home/home_page.dart';
import '../../modules/sales/sales_page.dart';
import '../../modules/stok/stok_page.dart';
import '../../shared/repositories/customer_repository.dart';
import '../../shared/services/remote_data_service_impl.dart';
import '../../shared/widgets/scaffold_with_navigation_bar.dart';

part 'route_name.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
                    builder:
                        (context, state) => RepositoryProvider(
                          create:
                              (context) => CustomerRepository(
                                remote: RemoteDataServiceImpl.instance,
                              ),
                          child: BlocProvider(
                            create:
                                (context) => CustomerListCubit(
                                  customerRepository:
                                      context.read<CustomerRepository>(),
                                ),
                            child: const CustomersPage(),
                          ),
                        ),
                    routes: [
                      GoRoute(
                        path: RouteName.createCustomer.path,
                        name: RouteName.createCustomer.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder:
                            (context, state) => RepositoryProvider(
                              create:
                                  (context) => CustomerRepository(
                                    remote: RemoteDataServiceImpl.instance,
                                  ),
                              child: BlocProvider(
                                create:
                                    (context) => CustomerCreateCubit(
                                      customerRepository:
                                          context.read<CustomerRepository>(),
                                    ),
                                child: const CustomerCreatePage(),
                              ),
                            ),
                      ),
                      GoRoute(
                        path: RouteName.customersDetails.path,
                        name: RouteName.customersDetails.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => const CustomersPage(),
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
