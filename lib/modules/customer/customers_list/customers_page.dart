import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/utils/message_mixin.dart';
import 'cubit/customer_list_cubit.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> with MessageMixin {
  late final CustomerListCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<CustomerListCubit>();
    _cubit.fetchAllCustomers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerListCubit, CustomerListState>(
      listener: (context, state) {
        if (state is CustomListError) {
          showError(context, 'Erro ao carregar clientes');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Clientes')),
        body: BlocSelector<CustomerListCubit, CustomerListState, bool>(
          selector: (state) => state is CustomerListLoading,
          builder: (context, isLoading) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final customers = _cubit.customers;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await context.pushNamed(
                          RouteName.createCustomer.name,
                        );
                        if (result == true) {
                          _cubit.fetchAllCustomers();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.darkPrimary300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Novo cliente',
                        style: TextStyle(
                          color: AppColors.darkPrimary300,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  if (customers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(child: Text('Nenhum cliente encontrado')),
                    )
                  else
                    Column(
                      spacing: 12,
                      children:
                          customers
                              .map(
                                (c) =>
                                    CustomerInfo(name: c.name, phone: c.phone),
                              )
                              .toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomerInfo extends StatelessWidget {
  const CustomerInfo({super.key, required this.name, required this.phone});

  final String name;
  final String phone;

  String getInitials(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 408,
      padding: const EdgeInsets.only(top: 8, right: 24, bottom: 8, left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.darkBg200,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.lightAvatar200,
            radius: 24,
            child: Text(
              getInitials(name),
              style: const TextStyle(
                color: AppColors.lightAvatar100,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              context.goNamed(
                RouteName.customersDetails.name,
                extra: {'name': name, 'phone': phone},
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(phone, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
