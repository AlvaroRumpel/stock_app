import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/entities/product.dart';
import '../../shared/entities/sale.dart';
import '../../shared/entities/sale_item.dart';
import '../../shared/utils/app_assets.dart';
import '../../shared/utils/context_extensions.dart';
import '../../shared/utils/string_extensions.dart';
import '../../shared/widgets/custom_tab_bar.dart';
import 'cubit/home_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final HomeCubit _cubit;
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void initState() {
    _cubit = context.read<HomeCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cubit.loadDashboard();
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeData) {
            return RefreshIndicator(
              onRefresh: () => _cubit.loadDashboard(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: CustomTabBar(
                      tabController: _tabController,
                      tabs: ['Geral', 'Vendas', 'Faturamento'],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _GeralTab(data: state.geral),
                        _VendasTab(data: state.vendas),
                        _FaturamentoTab(data: state.faturamento),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is HomeError) {
            return const Center(child: Text('Erro ao carregar dashboard'));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

// --- Geral Tab ---

class _GeralTab extends StatelessWidget {
  final HomeGeralData data;
  const _GeralTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _MetricCard(
                  value: '${data.availableBarrelsCount}',
                  label: 'Barris\ndisponíveis',
                ),
              ),
              Expanded(
                child: _MetricCard(
                  value: '${data.nearExpiryCount}',
                  label: 'Próximos da\nvalidade',
                ),
              ),
              Expanded(
                child: _MetricCard(
                  value: '${data.availableLiters}',
                  label: 'Litros\ndisponíveis',
                ),
              ),
            ],
          ),
          if (data.nearExpiryBarrels.isNotEmpty) ...[
            Text(
              'Próximos da validade',
              style: context.textStyle.headlineSmall,
            ),
            ...data.nearExpiryBarrels.expand(
              (b) => _barrelDisplayItems(b).map(
                (item) => _BarrelListCard(
                  product: item.$1,
                  volumeLabel: item.$2,
                  qty: item.$3,
                  isNearExpiry: true,
                ),
              ),
            ),
          ],
          if (data.rentedDispensers.isNotEmpty) ...[
            Text(
              'Chopeiras alugadas',
              style: context.textStyle.headlineSmall,
            ),
            ...data.rentedDispensers.map(
              (d) => _DispenserListCard(product: d),
            ),
          ],
        ],
      ),
    );
  }
}

// --- Vendas Tab ---

class _VendasTab extends StatelessWidget {
  final HomeVendasData data;
  const _VendasTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _MetricCard(
                  value: '${data.salesCount}',
                  label: 'Vendas\nrealizadas',
                ),
              ),
              Expanded(
                child: _MetricCard(
                  value: '${data.barrelsSold}',
                  label: 'Barris\nvendidos',
                ),
              ),
              Expanded(
                child: _MetricCard(
                  value: '${data.litersSold}',
                  label: 'Litros\nvendidos',
                ),
              ),
            ],
          ),
          Text('Últimas vendas', style: context.textStyle.headlineSmall),
          if (data.recentSales.isEmpty)
            const Text('Nenhuma venda registrada')
          else
            ...data.recentSales.map((sale) => _SaleCard(sale: sale)),
        ],
      ),
    );
  }
}

// --- Faturamento Tab ---

class _FaturamentoTab extends StatelessWidget {
  final HomeFaturamentoData data;
  const _FaturamentoTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _MetricCard(
                  value: data.revenue.toCurrencyFixed,
                  label: 'Faturamento\nno período',
                ),
              ),
              Expanded(
                child: _MetricCard(
                  value: '${data.pendingPaymentsCount}',
                  label: 'Pagamentos\npendentes',
                ),
              ),
              Expanded(
                child: _MetricCard(
                  value: data.avgSaleValue.toCurrencyFixed,
                  label: 'Valor médio\nda venda',
                ),
              ),
            ],
          ),
          Text('Maiores vendas', style: context.textStyle.headlineSmall),
          if (data.topSales.isEmpty)
            const Text('Nenhuma venda registrada')
          else
            ...data.topSales.map((sale) => _SaleCard(sale: sale)),
        ],
      ),
    );
  }
}

// --- Shared Widgets ---

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;

  const _MetricCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBg200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            value,
            style: context.textStyle.headlineSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: context.textStyle.bodySmall?.copyWith(
              color: AppColors.darkPrimary300,
            ),
          ),
        ],
      ),
    );
  }
}

List<(Product, String, int)> _barrelDisplayItems(Product barrel) {
  return [
    if ((barrel.qty30l ?? 0) > 0) (barrel, '30L', barrel.qty30l!),
    if ((barrel.qty50l ?? 0) > 0) (barrel, '50L', barrel.qty50l!),
  ];
}

class _BarrelListCard extends StatelessWidget {
  final Product product;
  final String volumeLabel;
  final int qty;
  final bool isNearExpiry;

  const _BarrelListCard({
    required this.product,
    required this.volumeLabel,
    required this.qty,
    this.isNearExpiry = false,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: () => context.pushNamed(
              RouteName.detailBarrel.name,
              pathParameters: {'id': product.id},
            ),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkBg200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                spacing: 12,
                children: [
                  SizedBox(
                    height: 40,
                    child: Image.asset(AppAssets.barrel),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
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
                            if (product.batchNumber != null) ...[
                              Container(
                                color: AppColors.darkAvatar100,
                                height: 16,
                                width: 1,
                              ),
                              Text(
                                'Lote: ${product.batchNumber}',
                                style: context.textStyle.labelLarge,
                              ),
                            ],
                            if (product.expirationDate != null) ...[
                              Container(
                                color: AppColors.darkAvatar100,
                                height: 16,
                                width: 1,
                              ),
                              Text(
                                'Validade: ${product.expirationDate.toStringFixed}',
                                style: context.textStyle.bodyLarge,
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
          ),
        ],
      ),
    );
  }
}

class _DispenserListCard extends StatelessWidget {
  final Product product;

  const _DispenserListCard({required this.product});

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
              backgroundColor: const Color(0xFFF39000),
              label: Text(
                'Indisponível',
                style: context.textStyle.labelSmall,
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkBg200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                spacing: 12,
                children: [
                  SizedBox(
                    height: 40,
                    child: Image.asset(AppAssets.faucet),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          'Chopeira - ${product.identifyNumber}',
                          style: context.textStyle.headlineSmall,
                        ),
                        if (product.returnDate != null)
                          Text(
                            'Previsão devolução: ${product.returnDate.toStringFixed}',
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
                    size: 16,
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

class _SaleCard extends StatelessWidget {
  final Sale sale;

  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final items = sale.items ?? [];
    final barrelSummary = _buildBarrelSummary(items);
    final dispenserCount = items
        .where((i) => i.volume == 'dispenser')
        .fold<int>(0, (s, i) => s + i.quantity);

    final dateLabel = _buildDateLabel(sale);

    return InkWell(
      onTap: () => context.pushNamed(
        RouteName.saleDetails.name,
        pathParameters: {'id': sale.id},
      ),
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
                    sale.customer?.name ?? 'Cliente',
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
