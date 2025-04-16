import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/utils/context_extensions.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/string_extensions.dart';
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
          showError(context, 'Nenhum Cliente Cadastrado');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Clientes')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            spacing: 16,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () async {
                    final result =
                        (await context.pushNamed<bool>(
                          RouteName.createCustomer.name,
                        )) ??
                        false;

                    if (result) {
                      _cubit.fetchAllCustomers();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Novo cliente',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              BlocBuilder<CustomerListCubit, CustomerListState>(
                builder: (context, state) {
                  if (state is CustomerListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final customers =
                      state is CustomerListSuccess ? state.customers : null;

                  if (customers == null) {
                    return const Center(
                      child: Text('Nenhum cliente encontrado'),
                    );
                  }

                  return Visibility(
                    visible: customers.isNotEmpty,
                    replacement: const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(child: Text('Nenhum cliente encontrado')),
                    ),
                    child: Expanded(
                      child: ListView.separated(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          return _CustomerCard(
                            name: customers[index].name,
                            phone: customers[index].phone,
                            id: customers[index].id,
                          );
                        },
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.name,
    required this.phone,
    required this.id,
  });

  final String name;
  final String id;
  final String phone;

  String get initials {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          context.goNamed(
            RouteName.customersDetails.name,
            pathParameters: {'id': id},
          );
        },
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          width: context.width,
          padding: const EdgeInsets.only(
            top: 8,
            right: 24,
            bottom: 8,
            left: 16,
          ),
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
                  initials,
                  style: const TextStyle(
                    color: AppColors.lightAvatar100,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Column(
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
                  Text(
                    phone.formatAsPhoneNumber(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
