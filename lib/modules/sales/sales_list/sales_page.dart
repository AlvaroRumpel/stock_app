import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/entities/sale.dart';
import '../../../shared/entities/sale_item.dart';
import '../../../shared/utils/app_assets.dart';
import '../../../shared/utils/context_extensions.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_tab_bar.dart';
import 'cubit/sales_cubit.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage>
    with SingleTickerProviderStateMixin {
  late final SalesCubit _cubit;
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    _cubit = context.read<SalesCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cubit.getSales();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            CustomTabBar(
              tabController: _tabController,
              tabs: ['Em aberto', 'Devolvidas'],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton.outlined(
                expanded: false,
                onPressed: () async {
                  final result =
                      (await context.pushNamed<bool>(
                        RouteName.createSale.name,
                      )) ??
                      false;
                  if (result) _cubit.getSales();
                },
                child: const Text('Nova venda'),
              ),
            ),
            BlocSelector<SalesCubit, SalesState,
                (List<Sale>, List<Sale>)>(
              selector: (state) {
                return state is SalesData
                    ? (state.activeSales, state.historySales)
                    : ([], []);
              },
              builder: (context, state) {
                return Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _SalesList(
                        sales: state.$1,
                        emptyMessage: 'Nenhuma venda ativa',
                        onRefresh: () => _cubit.getSales(),
                      ),
                      _SalesList(
                        sales: state.$2,
                        emptyMessage: 'Nenhuma venda no histórico',
                        onRefresh: () => _cubit.getSales(),
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

class _SalesList extends StatelessWidget {
  final List<Sale> sales;
  final String emptyMessage;
  final VoidCallback onRefresh;

  const _SalesList({
    required this.sales,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final sale = sales[index];
        return _SaleCard(sale: sale, onReturn: onRefresh);
      },
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemCount: sales.length,
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onReturn;

  const _SaleCard({required this.sale, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final items = sale.items ?? [];
    final barrelSummary = _buildBarrelSummary(items);
    final dispenserCount = items
        .where((i) => i.volume == 'dispenser')
        .fold<int>(0, (s, i) => s + i.quantity);

    final dateLabel = _buildDateLabel(sale);

    return InkWell(
      onTap: () async {
        await context.pushNamed(
          RouteName.saleDetails.name,
          pathParameters: {'id': sale.id},
        );
        onReturn();
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBg200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    dateLabel,
                    style: context.textStyle.bodySmall?.copyWith(
                      color: AppColors.darkPrimary300,
                    ),
                  ),
                  Text(
                    sale.customer?.name ?? 'Cliente não informado',
                    style: context.textStyle.headlineSmall,
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      if (barrelSummary.isNotEmpty) ...[
                        Image.asset(AppAssets.barrel, height: 18),
                        Text(
                          barrelSummary,
                          style: context.textStyle.bodySmall?.copyWith(
                            color: AppColors.darkAvatar100,
                          ),
                        ),
                      ],
                      if (barrelSummary.isNotEmpty && dispenserCount > 0)
                        Container(
                          color: AppColors.darkAvatar100,
                          height: 14,
                          width: 1,
                        ),
                      if (dispenserCount > 0) ...[
                        Image.asset(AppAssets.faucet, height: 18),
                        Text(
                          '$dispenserCount X chopeira',
                          style: context.textStyle.bodySmall?.copyWith(
                            color: AppColors.darkAvatar100,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.darkPrimary300,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _buildBarrelSummary(List<SaleItem> items) {
    final qty30 = items
        .where((i) => i.volume == '30')
        .fold<int>(0, (s, i) => s + i.quantity);
    final qty50 = items
        .where((i) => i.volume == '50')
        .fold<int>(0, (s, i) => s + i.quantity);

    final parts = <String>[];
    if (qty30 > 0) parts.add('$qty30 X 30L');
    if (qty50 > 0) parts.add('$qty50 X 50L');
    return parts.join(' – ');
  }

  String _buildDateLabel(Sale sale) {
    if (sale.pickupDate != null && sale.returnDate != null) {
      return 'Retirada: ${sale.pickupDate.toStringFixed} - Devolução: ${sale.returnDate.toStringFixed}';
    }
    return sale.createdAt.toStringFixed;
  }
}
