import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../modules/customer/customer_create/cubit/customer_create_cubit.dart';
import '../../modules/customer/customer_create/customer_create_page.dart';
import '../../modules/customer/customer_details/bloc/customer_details_cubit.dart';
import '../../modules/customer/customer_details/customer_details.dart';
import '../../modules/customer/customers_list/cubit/customer_list_cubit.dart';
import '../../modules/customer/customers_list/customers_page.dart';
import '../../modules/home/home_page.dart';
import '../../modules/sales/sales_page.dart';
import '../../modules/stok/barrel_create/barrel_create_page.dart';
import '../../modules/stok/barrel_create/cubit/barrel_create_cubit.dart';
import '../../modules/stok/barrel_detail/barrel_detail_page.dart';
import '../../modules/stok/barrel_detail/cubit/barrel_detail_cubit.dart';
import '../../modules/stok/dispenser_create/cubit/dispenser_create_cubit.dart';
import '../../modules/stok/dispenser_create/dispenser_create_page.dart';
import '../../modules/stok/stok_list/cubit/stok_cubit.dart';
import '../../modules/stok/stok_list/stok_page.dart';
import '../../shared/repositories/customer_repository.dart';
import '../../shared/repositories/product_repository.dart';
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
                    builder:
                        (context, state) => RepositoryProvider(
                          create:
                              (context) => ProductRepository(
                                remote: RemoteDataServiceImpl.instance,
                              ),
                          child: BlocProvider(
                            create:
                                (context) => StokCubit(
                                  repo: context.read<ProductRepository>(),
                                ),
                            child: const StokPage(),
                          ),
                        ),
                    routes: [
                      GoRoute(
                        path: RouteName.createBarrel.path,
                        name: RouteName.createBarrel.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder:
                            (context, state) => RepositoryProvider(
                              create:
                                  (context) => ProductRepository(
                                    remote: RemoteDataServiceImpl.instance,
                                  ),
                              child: BlocProvider(
                                create:
                                    (context) => BarrelCreateCubit(
                                      repo: context.read<ProductRepository>(),
                                    ),
                                child: const BarrelCreatePage(),
                              ),
                            ),
                      ),
                      GoRoute(
                        path: RouteName.createDispenser.path,
                        name: RouteName.createDispenser.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder:
                            (context, state) => RepositoryProvider(
                              create:
                                  (context) => ProductRepository(
                                    remote: RemoteDataServiceImpl.instance,
                                  ),
                              child: BlocProvider(
                                create:
                                    (context) => DispenserCreateCubit(
                                      repo: context.read<ProductRepository>(),
                                    ),
                                child: const DispenserCreatePage(),
                              ),
                            ),
                      ),
                      GoRoute(
                        path: '${RouteName.detailBarrel.path}/:id',
                        name: RouteName.detailBarrel.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return RepositoryProvider(
                            create:
                                (context) => ProductRepository(
                                  remote: RemoteDataServiceImpl.instance,
                                ),
                            child: BlocProvider(
                              create:
                                  (context) => BarrelDetailCubit(
                                    repo: context.read<ProductRepository>(),
                                  ),
                              child: BarrelDetailPage(productId: id),
                            ),
                          );
                        },
                      ),
                    ],
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
                        builder: (context, state) {
                          final customerId = state.uri.queryParameters['id'];

                          return RepositoryProvider(
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
                              child: CustomerCreatePage(customerId: customerId),
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: '${RouteName.customersDetails.path}/:id',
                        name: RouteName.customersDetails.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;

                          return RepositoryProvider(
                            create:
                                (context) => CustomerRepository(
                                  remote: RemoteDataServiceImpl.instance,
                                ),
                            child: BlocProvider(
                              create:
                                  (context) => CustomerDetailCubit(
                                    customerRepository:
                                        context.read<CustomerRepository>(),
                                  ),
                              child: CustomerDetailsPage(customerId: id),
                            ),
                          );
                        },
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
