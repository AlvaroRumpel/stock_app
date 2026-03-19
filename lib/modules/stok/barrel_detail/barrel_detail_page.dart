import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/context_extensions.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import 'cubit/barrel_detail_cubit.dart';

class BarrelDetailPage extends StatefulWidget {
  final String productId;
  const BarrelDetailPage({super.key, required this.productId});

  @override
  State<BarrelDetailPage> createState() => _BarrelDetailPageState();
}

class _BarrelDetailPageState extends State<BarrelDetailPage> {
  late final _cubit = context.read<BarrelDetailCubit>();

  @override
  void initState() {
    _cubit.load(widget.productId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BarrelDetailCubit, BarrelDetailState>(
      listener: (context, state) {
        if (state is BarrelDetailDeleted) {
          context.pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: Container(
          width: context.width,
          height: context.height,
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.darkBg200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: BlocBuilder<BarrelDetailCubit, BarrelDetailState>(
              builder: (context, state) {
                if (state is BarrelDetailError) {
                  return const Center(
                    child: Text('Erro ao carregar os detalhes'),
                  );
                }

                if (state is BarrelDetailLoaded) {
                  return Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelAndValue(
                        label: 'Número do lote',
                        value: state.barrel.batchNumber ?? 'N/A',
                      ),
                      LabelAndValue(
                        label: 'Validade',
                        value: state.barrel.expirationDate.toStringFixed,
                      ),
                      LabelAndValue(
                        label: 'Quantidade',
                        value:
                            state.barrel.availableQuantity?.toString() ?? 'N/A',
                      ),
                      LabelAndValue(
                        label: 'Preço de custo',
                        value: state.barrel.costPrice.toCurrencyFixed,
                      ),
                      LabelAndValue(
                        label: 'Preço de venda',
                        value: state.barrel.salePrice.toCurrencyFixed,
                      ),
                      LabelAndValue(
                        label: 'Volume',
                        value:
                            '${state.barrel.volume?.volume.toString() ?? 'N/A'} litros',
                      ),
                      LabelAndValue(
                        label: 'Observação',
                        value: state.barrel.observation ?? 'N/A',
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            spacing: 16,
            children: [
              Expanded(
                child: CustomButton.outlined(
                  onPressed: () {},
                  child: const Text('Editar'),
                ),
              ),
              Expanded(
                child: CustomButton.outlined(
                  onPressed: () async {
                    final confirm =
                        (await context.openBottomSheet<bool>(
                          _ConfirmDeleteBottomSheet(),
                        )) ??
                        false;

                    if (confirm) {
                      await _cubit.deleteProduct(widget.productId);
                    }
                  },
                  child: const Text('Remover'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LabelAndValue extends StatelessWidget {
  final String label;
  final String value;
  const LabelAndValue({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyle.titleMedium),
        Text(value, style: context.textStyle.headlineSmall),
      ],
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
            'Deseja remover este barril?',
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
    );
  }
}
