import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/context_extensions.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import 'cubit/sale_detail_cubit.dart';

class SaleDetailPage extends StatefulWidget {
  final String saleId;
  const SaleDetailPage({super.key, required this.saleId});

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> with MessageMixin {
  late final SaleDetailCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<SaleDetailCubit>();
    _cubit.loadSale(widget.saleId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleDetailCubit, SaleDetailState>(
      listener: (context, state) {
        if (state is SaleDetailError) {
          showError(context, 'Erro ao processar solicitação');
        }
        if (state is SaleDetailDeleted) {
          context.pop(true);
          showSuccess(context, 'Venda removida com sucesso');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalhes da venda')),
        body: BlocBuilder<SaleDetailCubit, SaleDetailState>(
          builder: (context, state) {
            if (state is SaleDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SaleDetailLoaded) {
              final sale = state.sale;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer + Status
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
                                  sale.customer?.name ?? 'Cliente não informado',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Column(
                                spacing: 4,
                                children: [
                                  Badge(
                                    backgroundColor:
                                        _statusColor(sale.status),
                                    label: Text(
                                      sale.statusLocalized,
                                      style: context.textStyle.labelSmall,
                                    ),
                                  ),
                                  Badge(
                                    backgroundColor:
                                        sale.isPaid
                                            ? const Color(0xFF4A9A3B)
                                            : const Color(0xFFF39000),
                                    label: Text(
                                      sale.isPaid ? 'Pago' : 'Não pago',
                                      style: context.textStyle.labelSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          _InfoRow(
                            label: 'Telefone',
                            value: sale.customer?.phone ?? '-',
                          ),
                          _InfoRow(
                            label: 'Valor total',
                            value:
                                'R\$ ${sale.totalValue.toStringAsFixed(2)}',
                          ),
                          if (sale.pricePerLiter != null)
                            _InfoRow(
                              label: 'Preço/litro',
                              value:
                                  'R\$ ${sale.pricePerLiter!.toStringAsFixed(2)}',
                            ),
                          _InfoRow(
                            label: 'Data da venda',
                            value: sale.createdAt.toStringFixed,
                          ),
                          if (sale.pickupDate != null)
                            _InfoRow(
                              label: 'Data de retirada',
                              value: sale.pickupDate!.toStringFixed,
                            ),
                          if (sale.returnDate != null)
                            _InfoRow(
                              label: 'Data de devolução',
                              value: sale.returnDate!.toStringFixed,
                            ),
                          if (sale.notes.isNotNullAndNotEmpty)
                            _InfoRow(
                              label: 'Observações',
                              value: sale.notes!,
                            ),
                        ],
                      ),
                    ),

                    // Items
                    Text('Itens', style: context.textStyle.headlineSmall),
                    if (sale.items != null && sale.items!.isNotEmpty)
                      ...sale.items!.map(
                        (item) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.darkBg200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.volume == 'dispenser'
                                          ? 'Chopeira - ${item.product?.identifyNumber ?? 'N/A'}'
                                          : 'Barril - Lote ${item.product?.batchNumber ?? 'N/A'}',
                                      style: context.textStyle.labelLarge,
                                    ),
                                    Text(
                                      '${item.quantity}x ${item.volumeLabel} - R\$ ${item.unitPrice.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'R\$ ${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                                style: context.textStyle.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Text('Nenhum item'),
                  ],
                ),
              );
            }

            return const Center(child: Text('Venda não encontrada'));
          },
        ),
        bottomNavigationBar: BlocBuilder<SaleDetailCubit, SaleDetailState>(
          builder: (context, state) {
            if (state is! SaleDetailLoaded) return const SizedBox.shrink();
            final sale = state.sale;
            final status = sale.status;
            final isPaid = sale.isPaid;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  CustomButton.outlined(
                    expanded: false,
                    onPressed: () async {
                      final updated = await context.pushNamed<bool>(
                        RouteName.editSale.name,
                        pathParameters: {'id': widget.saleId},
                        extra: sale,
                      );
                      if (updated == true) {
                        await _cubit.loadSale(widget.saleId);
                      }
                    },
                    child: const Text('Editar'),
                  ),
                  if (status == 'pending')
                    CustomButton.outlined(
                      expanded: false,
                      onPressed: () =>
                          _cubit.markPickedUp(widget.saleId),
                      child: const Text('Marcar Retirado'),
                    ),
                  if (status == 'picked_up')
                    CustomButton.outlined(
                      expanded: false,
                      onPressed: () =>
                          _cubit.markReturned(widget.saleId),
                      child: const Text('Marcar Devolvido'),
                    ),
                  if (status == 'picked_up')
                    CustomButton.outlined(
                      expanded: false,
                      onPressed: () async {
                        final confirm =
                            (await context.openBottomSheet<bool>(
                              _ConfirmFinalizeBottomSheet(),
                            )) ??
                            false;
                        if (confirm) {
                          await _cubit.finalizeSale(widget.saleId);
                        }
                      },
                      child: const Text('Finalizar Venda'),
                    ),
                  if (status != 'returned')
                    CustomButton.outlined(
                      expanded: false,
                      onPressed: () async {
                        final updated = await context.pushNamed<bool>(
                          RouteName.addSaleItems.name,
                          pathParameters: {'id': widget.saleId},
                        );
                        if (updated == true) {
                          await _cubit.loadSale(widget.saleId);
                        }
                      },
                      child: const Text('Adicionar Itens'),
                    ),
                  if (!isPaid)
                    CustomButton.outlined(
                      expanded: false,
                      onPressed: () =>
                          _cubit.markPaid(widget.saleId),
                      child: const Text('Marcar Pago'),
                    ),
                  CustomButton.outlined(
                    expanded: false,
                    foregroundColor: AppColors.darkAccent100,
                    onPressed: () async {
                      final confirm =
                          (await context.openBottomSheet<bool>(
                            _ConfirmDeleteBottomSheet(),
                          )) ??
                          false;
                      if (confirm) {
                        await _cubit.deleteSale(widget.saleId);
                      }
                    },
                    child: const Text('Excluir'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
    'pending' => const Color(0xFFFFFFA1),
    'picked_up' => const Color(0xFF4A9A3B),
    'returned' => AppColors.darkPrimary300,
    _ => AppColors.darkPrimary300,
  };
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            '$label:',
            style: context.textStyle.titleMedium,
          ),
        ),
        Expanded(
          child: Text(value, style: context.textStyle.bodyLarge),
        ),
      ],
    );
  }
}

class _ConfirmFinalizeBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Finalizar Venda', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(
            'Deseja finalizar esta venda?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'A venda será marcada como devolvida e paga.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
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
                child: const Text('Finalizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmDeleteBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Atenção!', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(
            'Deseja remover esta venda?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Esta ação não poderá ser desfeita',
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
    );
  }
}
