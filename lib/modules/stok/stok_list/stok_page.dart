import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/entities/product.dart';
import '../../../shared/utils/app_assets.dart';
import '../../../shared/utils/context_extensions.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_tab_bar.dart';
import 'cubit/stok_cubit.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage>
    with SingleTickerProviderStateMixin {
  late final StokCubit _cubit;
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    _cubit = context.read<StokCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cubit.getProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estoque')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton.outlined(
                expanded: false,
                onPressed: () async {
                  final result =
                      (await context.openBottomSheet<bool>(
                        _AddProductBottomSheet(),
                      )) ??
                      false;
                  if (result) _cubit.getProducts();
                },
                child: const Text('Novo produto'),
              ),
            ),
            CustomTabBar(
              tabController: _tabController,
              tabs: ['Barris', 'Chopeiras'],
            ),
            BlocSelector<StokCubit, StokState, (List<Product>, List<Product>)>(
              selector: (state) {
                return state is StokData
                    ? (state.barrelList, state.dispenserList)
                    : ([], []);
              },
              builder: (context, state) {
                // Split barrel products by volume
                final barrelItems = [
                  for (final b in state.$1) ...[
                    if ((b.qty30l ?? 0) > 0) (b, '30L', b.qty30l!),
                    if ((b.qty50l ?? 0) > 0) (b, '50L', b.qty50l!),
                  ],
                ];

                return Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Visibility(
                        visible: barrelItems.isNotEmpty,
                        replacement: const Center(
                          child: Text('Nenhum barril encontrado'),
                        ),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            final item = barrelItems[index];
                            return _BarrelCard(
                              barrel: item.$1,
                              volumeLabel: item.$2,
                              qty: item.$3,
                            );
                          },
                          separatorBuilder:
                              (_, _) => const SizedBox(height: 16),
                          itemCount: barrelItems.length,
                        ),
                      ),
                      Visibility(
                        visible: state.$2.isNotEmpty,
                        replacement: const Center(
                          child: Text('Nenhuma chopeira encontrada'),
                        ),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            final dispenser = state.$2[index];
                            return _DispenserCard(dispenser: dispenser);
                          },
                          separatorBuilder:
                              (_, _) => const SizedBox(height: 16),
                          itemCount: state.$2.length,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProductBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        spacing: 24,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              final result =
                  (await context.pushNamed<bool>(
                    RouteName.createBarrel.name,
                  )) ??
                  false;

              if (result && context.mounted) {
                context.pop(true);
              }
            },
            borderRadius: BorderRadius.circular(30),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.darkBg200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(height: 40, child: Image.asset(AppAssets.barrel)),
                  Expanded(
                    child: Text(
                      'Barril',
                      style: context.textStyle.headlineSmall,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.darkPrimary300,
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final result =
                  (await context.pushNamed<bool>(
                    RouteName.createDispenser.name,
                  )) ??
                  false;

              if (result && context.mounted) {
                context.pop(true);
              }
            },
            borderRadius: BorderRadius.circular(30),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.darkBg200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(height: 40, child: Image.asset(AppAssets.faucet)),
                  Expanded(
                    child: Text(
                      'Chopeira',
                      style: context.textStyle.headlineSmall,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.darkPrimary300,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarrelCard extends StatelessWidget {
  final Product barrel;
  final String volumeLabel;
  final int qty;

  const _BarrelCard({
    required this.barrel,
    required this.volumeLabel,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    final isNearExpiry =
        (barrel.expirationDate?.difference(DateTime.now()).inDays ?? 8) <= 7;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          if (isNearExpiry)
            Positioned(
              right: 36,
              top: 8,
              child: Badge(
                backgroundColor: const Color(0xFFFFFFA1),
                label: Text(
                  'Próx. vencimento',
                  style: context.textStyle.labelSmall?.copyWith(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          InkWell(
            onTap: () async {
              await context.pushNamed(
                RouteName.detailBarrel.name,
                pathParameters: {'id': barrel.id},
                queryParameters: {'volume': volumeLabel.replaceAll('L', '')},
              );
              if (context.mounted) context.read<StokCubit>().getProducts();
            },
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.darkBg200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(height: 40, child: Image.asset(AppAssets.barrel)),
                  Expanded(
                    child: Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barril - $volumeLabel',
                          style: context.textStyle.headlineSmall,
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            Text(
                              'Qtd.: $qty',
                              style: context.textStyle.labelLarge,
                            ),
                            if (barrel.batchNumber != null) ...[
                              Container(
                                color: AppColors.darkAvatar100,
                                height: 16,
                                width: 1,
                              ),
                              Text(
                                'Lote: ${barrel.batchNumber}',
                                style: context.textStyle.labelLarge,
                              ),
                            ],
                            Container(
                              color: AppColors.darkAvatar100,
                              height: 16,
                              width: 1,
                            ),
                            Text(
                              'Validade: ${barrel.expirationDate.toStringFixed}',
                              style: context.textStyle.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.darkPrimary300,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DispenserCard extends StatelessWidget {
  final Product dispenser;

  const _DispenserCard({required this.dispenser});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            right: 36,
            top: 8,
            child: Badge(
              backgroundColor: dispenser.isAvailable
                  ? const Color(0xFF4A9A3B)
                  : const Color(0xFFF39000),
              label: Text(
                dispenser.isAvailable ? 'Disponível' : 'Indisponível',
                style: context.textStyle.labelSmall,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              await context.pushNamed(
                RouteName.detailDispenser.name,
                pathParameters: {'id': dispenser.id},
              );
              if (context.mounted) context.read<StokCubit>().getProducts();
            },
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.darkBg200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(height: 40, child: Image.asset(AppAssets.faucet)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'Chopeira - ${dispenser.identifyNumber ?? 'N/A'}',
                          style: context.textStyle.headlineSmall,
                        ),
                        if (!dispenser.isAvailable &&
                            dispenser.returnDate != null)
                          Text(
                            'Previsão devolução: ${dispenser.returnDate.toStringFixed}',
                            style: context.textStyle.bodySmall?.copyWith(
                              color: AppColors.darkPrimary300,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.darkPrimary300,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
