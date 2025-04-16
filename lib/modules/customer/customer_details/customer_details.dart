import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/repositories/customer_repository.dart';
import '../../../shared/utils/message_mixin.dart';
import 'bloc/customer_details_cubit.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailsPage({super.key, required this.customerId});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage>
    with MessageMixin {
  late final CustomerDetailCubit _cubit;
  bool _wasDeleted = false;

  @override
  void initState() {
    _cubit = CustomerDetailCubit(
      customerRepository: context.read<CustomerRepository>(),
    );
    _cubit.fetchCustomer(widget.customerId);
    super.initState();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerDetailCubit, CustomerDetailState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is CustomerDetailError) {
          showError(context, 'Erro ao processar solicitação');
        }

        if (state is CustomerDetailInitial && _wasDeleted) {
          showSuccess(context, 'Cliente deletado com sucesso');
          context.pop(true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Detalhes do Cliente')),
          body: Builder(
            builder: (context) {
              if (state is CustomerDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CustomerDetailSuccess) {
                final customer = state.customers;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    spacing: 24,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkBg200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: AppColors.darkPrimary300,
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: AppColors.darkAccent100,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Confirmação',
                                                ),
                                                content: const Text(
                                                  'Deseja realmente excluir este cliente?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text(
                                                      'Cancelar',
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: const Text(
                                                      'Excluir',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );

                                        if (confirm == true) {
                                          await _cubit.deleteCustomer(
                                            customer.id,
                                          );
                                          Navigator.of(context).pop(true);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Text('Celular:'),
                            Text(
                              customer.phone,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Text('Endereço:'),
                            Text(
                              customer.address ?? 'Sem endereço',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Text('Observações:'),
                            Text(
                              customer.observation?.isNotEmpty == true
                                  ? customer.observation!
                                  : 'Sem observações',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Cliente não encontrado'));
            },
          ),
        );
      },
    );
  }
}
