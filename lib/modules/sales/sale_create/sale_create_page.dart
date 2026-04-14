import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/entities/customer.dart';
import '../../../shared/entities/product.dart';
import '../../../shared/entities/sale_item.dart';
import '../../../shared/utils/context_extensions.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'cubit/sale_create_cubit.dart';

/// Represents a product+volume combination for the unified dropdown.
class _ProductOption {
  final Product product;
  final String volume; // '30', '50', or 'dispenser'

  const _ProductOption({required this.product, required this.volume});

  String get label {
    if (product.type == ProductTypeEnum.barrel) {
      return 'Barril - Lote ${product.batchNumber} - ${volume}L';
    }
    return 'Chopeira - ${product.identifyNumber}';
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

class SaleCreatePage extends StatefulWidget {
  const SaleCreatePage({super.key});

  @override
  State<SaleCreatePage> createState() => _SaleCreatePageState();
}

class _SaleCreatePageState extends State<SaleCreatePage> with MessageMixin {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _valueController = TextEditingController();
  final _returnDateController = TextEditingController();
  final _pickupDateController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _returnDate;
  DateTime? _pickupDate;
  bool _isPaid = false;
  bool _hasChanges = false;

  // Inline item editing state
  final List<_InlineItemState> _itemStates = [];

  late final SaleCreateCubit _cubit;

  void _onChanged() => setState(() => _hasChanges = true);

  Future<bool> _confirmDiscard() async {
    final result = await context.openBottomSheet<bool>(
      const _UnsavedChangesSheet(),
    );
    return result == true;
  }

  Future<void> _handleCancel() async {
    if (!_hasChanges) {
      context.pop();
      return;
    }
    final confirmed = await _confirmDiscard();
    if (confirmed && mounted) context.pop();
  }

  @override
  void initState() {
    _cubit = context.read<SaleCreateCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cubit.loadData();
    });
    // Start with one empty item slot
    _itemStates.add(_InlineItemState());
    _addressController.addListener(_onChanged);
    _notesController.addListener(_onChanged);
    super.initState();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _valueController.dispose();
    _returnDateController.dispose();
    _pickupDateController.dispose();
    _notesController.dispose();
    for (final item in _itemStates) {
      item.dispose();
    }
    super.dispose();
  }

  double _calculateSubtotal() {
    double total = 0;
    for (final itemState in _itemStates) {
      if (itemState.selectedOption == null) continue;
      final qty = int.tryParse(itemState.qtyController.text) ?? 0;
      final price = double.tryParse(
            itemState.unitPriceController.text.toCurrencyFixed,
          ) ??
          0;
      total += qty * price;
    }
    return total;
  }

  void _updateTotalFromItems() {
    final subtotal = _calculateSubtotal();
    final formatted = subtotal.toStringAsFixed(2).replaceAll('.', ',');
    _valueController.text = formatted;
    setState(() {});
  }

  List<_ProductOption> _buildProductOptions(List<Product> products) {
    final options = <_ProductOption>[];
    for (final p in products) {
      if (p.type == ProductTypeEnum.barrel) {
        if ((p.qty30l ?? 0) > 0) {
          options.add(_ProductOption(product: p, volume: '30'));
        }
        if ((p.qty50l ?? 0) > 0) {
          options.add(_ProductOption(product: p, volume: '50'));
        }
      } else {
        options.add(_ProductOption(product: p, volume: 'dispenser'));
      }
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleCreateCubit, SaleCreateState>(
      listener: (context, state) {
        if (state is SaleCreateSuccess) {
          context.pop(true);
          showSuccess(context, 'Venda cadastrada com sucesso!');
          return;
        }

        if (state is SaleCreateValidationError) {
          showError(context, state.message);
          return;
        }
      },
      child: PopScope(
        canPop: !_hasChanges,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop && _hasChanges) {
            final confirmed = await _confirmDiscard();
            if (confirmed && mounted) context.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: _handleCancel,
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Nova venda'),
          ),
        body: BlocSelector<SaleCreateCubit, SaleCreateState, bool>(
          selector: (state) => state is SaleCreateLoading,
          builder: (context, isLoading) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preencha os dados para cadastrar uma venda',
                          style: context.textStyle.bodyLarge?.copyWith(
                            color: AppColors.darkPrimary300,
                          ),
                        ),

                        // Customer selector (search bottom sheet)
                        BlocSelector<SaleCreateCubit, SaleCreateState,
                            (List<Customer>, Customer?)>(
                          selector: (state) {
                            if (state is SaleCreateData) {
                              return (
                                state.customers,
                                state.selectedCustomer,
                              );
                            }
                            return (<Customer>[], null);
                          },
                          builder: (context, data) {
                            final (customers, selected) = data;
                            return FormField<Customer>(
                              initialValue: selected,
                              validator: (_) => _cubit.state is SaleCreateData &&
                                      (_cubit.state as SaleCreateData)
                                              .selectedCustomer ==
                                          null
                                  ? 'Selecione um cliente'
                                  : null,
                              builder: (field) {
                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    final picked =
                                        await context
                                            .openBottomSheet<Customer>(
                                              _CustomerPickerSheet(
                                                customers: customers,
                                                cubit: _cubit,
                                              ),
                                            );
                                    if (picked != null) {
                                      _cubit.selectCustomer(picked);
                                      final state = _cubit.state;
                                      if (state is SaleCreateData &&
                                          state.useCustomerAddress &&
                                          picked.address != null) {
                                        _addressController.text =
                                            picked.address!;
                                      }
                                      field.didChange(picked);
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Cliente *',
                                      errorText: field.errorText,
                                      suffixIcon: const Icon(
                                        Icons.arrow_drop_down,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(
                                          color: AppColors.darkPrimary300,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                        borderSide: BorderSide(
                                          color: AppColors.darkPrimary300,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      selected?.name ?? 'Selecione um cliente',
                                      style: selected == null
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .hintColor,
                                              )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // Use customer address checkbox
                        BlocSelector<SaleCreateCubit, SaleCreateState, bool>(
                          selector: (state) {
                            if (state is SaleCreateData) {
                              return state.useCustomerAddress;
                            }
                            return false;
                          },
                          builder: (context, useCustomerAddress) {
                            return Row(
                              children: [
                                Checkbox(
                                  value: useCustomerAddress,
                                  onChanged: (v) {
                                    _cubit
                                        .toggleUseCustomerAddress(v ?? false);
                                    if (v == true) {
                                      final state = _cubit.state;
                                      if (state is SaleCreateData &&
                                          state.selectedCustomer?.address !=
                                              null) {
                                        _addressController.text =
                                            state.selectedCustomer!.address!;
                                      }
                                    }
                                  },
                                  side: const BorderSide(
                                    color: AppColors.darkPrimary300,
                                  ),
                                ),
                                Text(
                                  'Utilizar endereço do cadastro',
                                  style: context.textStyle.bodyLarge?.copyWith(
                                    color: AppColors.darkPrimary300,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Address (required)
                        CustomTextField(
                          controller: _addressController,
                          hintText: 'Endereço',
                          labelText: 'Endereço',
                          validators: [Required()],
                        ),

                        // Items section
                        BlocSelector<SaleCreateCubit, SaleCreateState,
                            List<Product>>(
                          selector: (state) {
                            if (state is SaleCreateData) return state.products;
                            return [];
                          },
                          builder: (context, products) {
                            final options = _buildProductOptions(products);
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.darkBg200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [
                                  Text(
                                    'Itens',
                                    style: context.textStyle.headlineSmall,
                                  ),
                                  if (options.isEmpty)
                                    const Text(
                                      'Nenhum produto disponível em estoque',
                                    ),
                                  for (int i = 0; i < _itemStates.length; i++)
                                    _InlineItemWidget(
                                      index: i,
                                      itemState: _itemStates[i],
                                      options: options,
                                      onItemChanged: _updateTotalFromItems,
                                      onRemove: _itemStates.length > 1
                                          ? () {
                                              setState(() {
                                                _itemStates[i].dispose();
                                                _itemStates.removeAt(i);
                                              });
                                              _updateTotalFromItems();
                                            }
                                          : null,
                                    ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _itemStates.add(_InlineItemState());
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: AppColors.darkAvatar100,
                                      size: 20,
                                    ),
                                    label: Text(
                                      'Adicionar item',
                                      style: context.textStyle.bodyLarge
                                          ?.copyWith(
                                            color: AppColors.darkPrimary300,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Value (auto-filled with subtotal, editable)
                        CustomTextField(
                          controller: _valueController,
                          hintText: 'Valor total',
                          labelText: 'Valor total',
                          prefix: const Text('R\$ '),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            RealCurrencyInputFormatterNoSymbol(),
                          ],
                          validators: [Required()],
                        ),

                        // Is paid checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isPaid,
                              onChanged: (v) => setState(() {
                                _isPaid = v ?? false;
                                _hasChanges = true;
                              }),
                              side: const BorderSide(
                                color: AppColors.darkPrimary300,
                              ),
                            ),
                            Text(
                              'Valor pago',
                              style: context.textStyle.bodyLarge?.copyWith(
                                color: AppColors.darkPrimary300,
                              ),
                            ),
                          ],
                        ),

                        // Pickup date
                        CustomTextField(
                          controller: _pickupDateController,
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              initialDate: _pickupDate ?? DateTime.now(),
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.utc(2100),
                              locale: const Locale('pt', 'BR'),
                            );

                            if (selectedDate != null) {
                              _pickupDateController.text =
                                  selectedDate.toStringFixed;
                              setState(() {
                                _pickupDate = selectedDate;
                                _hasChanges = true;
                              });
                            }
                          },
                          hintText: 'Data retirada',
                          labelText: 'Data retirada',
                        ),

                        // Return date
                        CustomTextField(
                          controller: _returnDateController,
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              initialDate: _returnDate ?? _pickupDate ?? DateTime.now(),
                              context: context,
                              firstDate: _pickupDate ?? DateTime.now(),
                              lastDate: DateTime.utc(2100),
                              locale: const Locale('pt', 'BR'),
                            );

                            if (selectedDate != null) {
                              _returnDateController.text =
                                  selectedDate.toStringFixed;
                              setState(() {
                                _returnDate = selectedDate;
                                _hasChanges = true;
                              });
                            }
                          },
                          hintText: 'Data devolução',
                          labelText: 'Data devolução',
                        ),

                        // Notes
                        CustomTextField(
                          controller: _notesController,
                          hintText: 'Observações',
                          labelText: 'Observações',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading overlay during submission
                BlocSelector<SaleCreateCubit, SaleCreateState, bool>(
                  selector: (state) {
                    if (state is SaleCreateData) return state.isSubmitting;
                    return false;
                  },
                  builder: (context, isSubmitting) {
                    if (!isSubmitting) return const SizedBox.shrink();
                    return Container(
                      color: Colors.black54,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_cubit.state is! SaleCreateData) return;

                    // Clear previous items and re-add from inline state
                    final data = _cubit.state as SaleCreateData;
                    while (data.items.isNotEmpty) {
                      _cubit.removeItem(0);
                    }

                    // Add items from inline state
                    for (final itemState in _itemStates) {
                      final option = itemState.selectedOption;
                      if (option == null) continue;
                      final qty =
                          int.tryParse(itemState.qtyController.text) ?? 1;
                      final unitPrice = double.tryParse(
                            itemState.unitPriceController.text.toCurrencyFixed,
                          ) ??
                          0;

                      _cubit.addItem(
                        SaleItem.newItem(
                          productId: option.product.id,
                          quantity: qty,
                          volume: option.volume,
                          unitPrice: unitPrice,
                          product: option.product,
                        ),
                      );
                    }

                    final totalValue = double.tryParse(
                          _valueController.text.toCurrencyFixed,
                        ) ??
                        0;

                    await _cubit.createSale(
                      totalValue: totalValue,
                      isPaid: _isPaid,
                      address: _addressController.text.isEmpty
                          ? null
                          : _addressController.text,
                      returnDate: _returnDate,
                      pickupDate: _pickupDate,
                      notes: _notesController.text.isEmpty
                          ? null
                          : _notesController.text,
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
              TextButton(
                onPressed: _handleCancel,
                child: Text(
                  'Cancelar',
                  style: context.textStyle.bodyLarge?.copyWith(
                    color: AppColors.darkPrimary300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _InlineItemState {
  _ProductOption? selectedOption;
  final TextEditingController qtyController = TextEditingController(text: '1');
  final TextEditingController unitPriceController = TextEditingController();

  void dispose() {
    qtyController.dispose();
    unitPriceController.dispose();
  }
}

class _InlineItemWidget extends StatefulWidget {
  final int index;
  final _InlineItemState itemState;
  final List<_ProductOption> options;
  final VoidCallback? onRemove;
  final VoidCallback onItemChanged;

  const _InlineItemWidget({
    required this.index,
    required this.itemState,
    required this.options,
    required this.onItemChanged,
    this.onRemove,
  });

  @override
  State<_InlineItemWidget> createState() => _InlineItemWidgetState();
}

class _InlineItemWidgetState extends State<_InlineItemWidget> {
  @override
  void initState() {
    super.initState();
    widget.itemState.qtyController.addListener(widget.onItemChanged);
    widget.itemState.unitPriceController.addListener(widget.onItemChanged);
  }

  @override
  void dispose() {
    widget.itemState.qtyController.removeListener(widget.onItemChanged);
    widget.itemState.unitPriceController.removeListener(widget.onItemChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final option = widget.itemState.selectedOption;
    final maxQty = option?.maxQuantity ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Item ${widget.index + 1}',
                style: context.textStyle.headlineSmall,
              ),
            ),
            if (widget.onRemove != null)
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.darkAccent100,
                  size: 20,
                ),
              ),
          ],
        ),

        // Unified product+volume selector
        DropdownButtonFormField<_ProductOption>(
          initialValue: widget.itemState.selectedOption,
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
          items: widget.options
              .map(
                (opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (newOption) {
            setState(() {
              widget.itemState.selectedOption = newOption;
              if (newOption != null) {
                // Auto-fill unit price
                final price = newOption.product.salePrice;
                if (price != null && price > 0) {
                  final formatted =
                      price.toStringAsFixed(2).replaceAll('.', ',');
                  widget.itemState.unitPriceController.text = formatted;
                } else {
                  widget.itemState.unitPriceController.text = '';
                }
                // Reset quantity to 1
                widget.itemState.qtyController.text = '1';
              }
            });
          },
        ),

        // Quantity (max limited to available stock)
        CustomTextField(
          controller: widget.itemState.qtyController,
          hintText: option != null ? 'Quantidade (máx: $maxQty)' : 'Quantidade',
          labelText:
              option != null ? 'Quantidade (máx: $maxQty)' : 'Quantidade',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validators: [
            Required(),
            if (option != null)
              Custom(
                validation: (value) {
                  final qty = int.tryParse(value ?? '') ?? 0;
                  if (qty <= 0) return 'Quantidade deve ser maior que 0';
                  if (maxQty > 0 && qty > maxQty) {
                    return 'Máximo disponível: $maxQty';
                  }
                  return null;
                },
              ),
          ],
        ),

        // Unit price
        CustomTextField(
          controller: widget.itemState.unitPriceController,
          hintText: 'Preço unitário',
          labelText: 'Preço unitário',
          prefix: const Text('R\$ '),
          keyboardType: TextInputType.number,
          inputFormatters: [RealCurrencyInputFormatterNoSymbol()],
        ),
      ],
    );
  }
}

class _CustomerPickerSheet extends StatefulWidget {
  final List<Customer> customers;
  final SaleCreateCubit cubit;

  const _CustomerPickerSheet({
    required this.customers,
    required this.cubit,
  });

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchController = TextEditingController();
  List<Customer> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.customers;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = widget.customers
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Buscar cliente...',
              labelText: 'Buscar',
              prefixIcon: Icons.search,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.add_circle_outline,
              color: AppColors.darkAvatar100,
            ),
            title: const Text('Criar novo cliente'),
            onTap: () async {
              final Customer? created =
                  await context.pushNamed(RouteName.createCustomer.name);
              if (created != null && context.mounted) {
                await widget.cubit.reloadCustomers();
                if (context.mounted) Navigator.of(context).pop(created);
              }
            },
          ),
          const Divider(height: 1, color: AppColors.darkPrimary300),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Nenhum cliente encontrado'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final customer = _filtered[i];
                      return ListTile(
                        title: Text(customer.name),
                        subtitle: customer.phone.isNotEmpty
                            ? Text(customer.phone)
                            : null,
                        onTap: () => Navigator.of(context).pop(customer),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _UnsavedChangesSheet extends StatelessWidget {
  const _UnsavedChangesSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Text(
            'Sair sem salvar?',
            style: context.textStyle.titleMedium,
          ),
          Text(
            'As alterações feitas serão perdidas.',
            style: context.textStyle.bodyMedium,
          ),
          const SizedBox(height: 4),
          CustomButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar editando'),
          ),
          CustomButton.outlined(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
