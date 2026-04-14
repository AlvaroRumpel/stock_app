import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/entities/product.dart';
import '../../../shared/entities/sale_item.dart';
import '../../../shared/repositories/product_repository.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../sale_detail/cubit/sale_detail_cubit.dart';

class _ProductOption {
  final Product product;
  final String volume;

  const _ProductOption({required this.product, required this.volume});

  String get label {
    if (product.type == ProductTypeEnum.barrel) {
      return 'Barril - Lote ${product.batchNumber} - ${volume}L';
    }
    return 'Chopeira - ${product.identifyNumber ?? 'N/A'}';
  }

  int get maxQuantity {
    if (product.type == ProductTypeEnum.dispenser) return 1;
    if (volume == '30') return product.qty30l ?? 0;
    if (volume == '50') return product.qty50l ?? 0;
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProductOption &&
          product.id == other.product.id &&
          volume == other.volume;

  @override
  int get hashCode => Object.hash(product.id, volume);
}

class AddItemsPage extends StatefulWidget {
  final String saleId;
  const AddItemsPage({super.key, required this.saleId});

  @override
  State<AddItemsPage> createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> with MessageMixin {
  final _formKey = GlobalKey<FormState>();
  _ProductOption? _selectedOption;
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  List<Product> _products = [];
  bool _loading = true;
  bool _saving = false;

  late final SaleDetailCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<SaleDetailCubit>();
    _loadProducts();
    super.initState();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final repo = context.read<ProductRepository>();
      final products = await repo.getProducts();
      setState(() {
        _products = products
            .where(
              (p) =>
                  p.isAvailable &&
                  (p.type == ProductTypeEnum.dispenser ||
                      (p.qty30l ?? 0) > 0 ||
                      (p.qty50l ?? 0) > 0),
            )
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<_ProductOption> get _options {
    final opts = <_ProductOption>[];
    for (final p in _products) {
      if (p.type == ProductTypeEnum.barrel) {
        if ((p.qty30l ?? 0) > 0) opts.add(_ProductOption(product: p, volume: '30'));
        if ((p.qty50l ?? 0) > 0) opts.add(_ProductOption(product: p, volume: '50'));
      } else {
        opts.add(_ProductOption(product: p, volume: 'dispenser'));
      }
    }
    return opts;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleDetailCubit, SaleDetailState>(
      listener: (context, state) {
        if (state is SaleDetailLoaded) {
          context.pop(true);
          showSuccess(context, 'Item adicionado com sucesso!');
        }
        if (state is SaleDetailError) {
          setState(() => _saving = false);
          showError(context, 'Erro ao adicionar item');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Adicionar item')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 16,
                    children: [
                      DropdownButtonFormField<_ProductOption>(
                        initialValue: _selectedOption,
                        validator: (v) => v == null ? 'Selecione um produto' : null,
                        decoration: const InputDecoration(
                          labelText: 'Produto',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: AppColors.darkPrimary300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(color: AppColors.darkPrimary300),
                          ),
                        ),
                        dropdownColor: AppColors.darkBg200,
                        isExpanded: true,
                        items: _options
                            .map(
                              (opt) => DropdownMenuItem(
                                value: opt,
                                child: Text(opt.label, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (opt) {
                          setState(() {
                            _selectedOption = opt;
                            if (opt != null) {
                              final price = opt.product.salePrice;
                              _priceController.text = price != null && price > 0
                                  ? price.toStringAsFixed(2).replaceAll('.', ',')
                                  : '';
                              _qtyController.text = '1';
                            }
                          });
                        },
                      ),
                      CustomTextField(
                        controller: _qtyController,
                        hintText: _selectedOption != null
                            ? 'Quantidade (máx: ${_selectedOption!.maxQuantity})'
                            : 'Quantidade',
                        labelText: _selectedOption != null
                            ? 'Quantidade (máx: ${_selectedOption!.maxQuantity})'
                            : 'Quantidade',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validators: [
                          Required(),
                          if (_selectedOption != null)
                            Custom(
                              validation: (value) {
                                final qty = int.tryParse(value ?? '') ?? 0;
                                if (qty <= 0) return 'Quantidade deve ser maior que 0';
                                final max = _selectedOption!.maxQuantity;
                                if (max > 0 && qty > max) {
                                  return 'Máximo disponível: $max';
                                }
                                return null;
                              },
                            ),
                        ],
                      ),
                      CustomTextField(
                        controller: _priceController,
                        hintText: 'Preço unitário',
                        labelText: 'Preço unitário',
                        prefix: const Text('R\$ '),
                        keyboardType: TextInputType.number,
                        inputFormatters: [RealCurrencyInputFormatterNoSymbol()],
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                enabled: !_saving,
                onPressed: () async {
                  if (_saving) return;
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => _saving = true);
                    final option = _selectedOption!;
                    final qty = int.tryParse(_qtyController.text) ?? 1;
                    final price = double.tryParse(
                          _priceController.text.toCurrencyFixed,
                        ) ??
                        0;
                    final item = SaleItem.newItem(
                      productId: option.product.id,
                      quantity: qty,
                      volume: option.volume,
                      unitPrice: price,
                      product: option.product,
                    );
                    await _cubit.addItemToSale(widget.saleId, item);
                  }
                },
                child: const Text('Adicionar'),
              ),
              CustomButton.outlined(
                onPressed: context.pop,
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
