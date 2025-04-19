import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/context_extensions.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/widgets/custom_button.dart';
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

  @override
  void initState() {
    _cubit = context.read<CustomerDetailCubit>();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: BlocConsumer<CustomerDetailCubit, CustomerDetailState>(
        listener: (context, state) {
          if (state is CustomerDetailError) {
            showError(context, 'Erro ao processar solicitação');
          }

          if (state is CustomerDetailDeleted) {
            context.pop();
            showSuccess(context, 'Cliente deletado com sucesso');
          }
        },
        builder: (context, state) {
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
                            Material(
                              color: AppColors.darkBg200,
                              child: Row(
                                spacing: 8,
                                children: [
                                  InkWell(
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 24,
                                      color: AppColors.darkPrimary300,
                                    ),
                                    onTap: () async {
                                      await context.pushNamed(
                                        RouteName.createCustomer.name,
                                        queryParameters: {'id': customer.id},
                                      );

                                      _cubit.fetchCustomer(customer.id);
                                    },
                                  ),
                                  InkWell(
                                    child: const Icon(
                                      Icons.delete_outlined,
                                      size: 24,
                                      color: AppColors.darkAccent100,
                                    ),
                                    onTap: () async {
                                      final confirm =
                                          (await context.openBottomSheet<bool>(
                                            _ConfirmDeleteBottomSheet(),
                                          )) ??
                                          false;

                                      if (confirm) {
                                        await _cubit.deleteCustomer(
                                          customer.id,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
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
                          customer.observation.isNotNullAndNotEmpty
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
  }
}

class _ConfirmDeleteBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Atenção', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Text(
              'Deseja remover este cliente da sua lista de contatos?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Está ação não poderá ser desfeita',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 24,
              children: [
                CustomButton.outlined(
                  onPressed: () => context.pop(false),
                  expanded: false,
                  child: const Text('Cancelar'),
                ),
                CustomButton.outlined(
                  onPressed: () => context.pop(true),
                  expanded: false,
                  foregroundColor: AppColors.darkAccent100,
                  child: const Text('Remover'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
