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
            CustomTabBar(
              tabController: _tabController,
              tabs: ['Barris', 'Chopeiras'],
            ),
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
            BlocSelector<StokCubit, StokState, (List<Product>, List<Product>)>(
              selector: (state) {
                return state is StokData
                    ? (state.barrelList, state.dispenserList)
                    : ([], []);
              },
              builder: (context, state) {
                return Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Visibility(
                        visible: state.$1.isNotEmpty,
                        replacement: const Center(
                          child: Text('Nenhum barril encontrado'),
                        ),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            final barrel = state.$1[index];
                            return _BarrelCard(barrel: barrel);
                          },
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 16),
                          itemCount: state.$1.length,
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
                              (_, __) => const SizedBox(height: 16),
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

  const _BarrelCard({required this.barrel});
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned(
            right: 36,
            top: 8,
            child: Visibility(
              visible:
                  (barrel.expirationDate?.difference(DateTime.now()).inDays ??
                      8) <=
                  7,
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
          ),
          InkWell(
            onTap: () async {
              await context.pushNamed(
                RouteName.detailBarrel.name,
                pathParameters: {'id': barrel.id},
              );

              if (context.mounted) context.read<StokCubit>().getProducts();
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
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barril - ${barrel.volume?.volume}L',
                          style: context.textStyle.headlineSmall,
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            Text(
                              'Qtd.: ${barrel.availableQuantity}',
                              style: context.textStyle.labelLarge,
                            ),
                            Container(
                              color: AppColors.darkAvatar100,
                              height: 20,
                              width: 1,
                            ),
                            Text(
                              'Lote: ${barrel.batchNumber}',
                              style: context.textStyle.bodyLarge,
                            ),
                            Container(
                              color: AppColors.darkAvatar100,
                              height: 20,
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
      child: Stack(
        children: [
          Positioned(
            right: 36,
            top: 8,
            child: Badge(
              backgroundColor:
                  dispenser.availableQuantity != null &&
                          dispenser.availableQuantity! > 0
                      ? const Color(0xFF4A9A3B)
                      : const Color(0xFFF39000),
              label: Text(
                dispenser.availableQuantity != null &&
                        dispenser.availableQuantity! > 0
                    ? 'Disponível'
                    : 'Indisponível',
                style: context.textStyle.labelSmall,
              ),
            ),
          ),
          InkWell(
            onTap: () {},
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
                      'Chopeira - ${dispenser.identifyNumber}',
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
