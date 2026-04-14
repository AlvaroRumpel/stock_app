import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/entities/sale.dart';
import '../../../shared/utils/context_extensions.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../sale_detail/cubit/sale_detail_cubit.dart';

class SaleEditPage extends StatefulWidget {
  final Sale sale;
  const SaleEditPage({super.key, required this.sale});

  @override
  State<SaleEditPage> createState() => _SaleEditPageState();
}

class _SaleEditPageState extends State<SaleEditPage> with MessageMixin {
  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  late final _addressController =
      TextEditingController(text: widget.sale.address ?? '');
  late final _notesController =
      TextEditingController(text: widget.sale.notes ?? '');
  late final _pickupDateController =
      TextEditingController(text: widget.sale.pickupDate?.toStringFixed ?? '');
  late final _returnDateController =
      TextEditingController(text: widget.sale.returnDate?.toStringFixed ?? '');

  late DateTime? _pickupDate = widget.sale.pickupDate;
  late DateTime? _returnDate = widget.sale.returnDate;

  late final SaleDetailCubit _cubit;

  void _onChanged() => setState(() => _hasChanges = true);

  @override
  void initState() {
    _cubit = context.read<SaleDetailCubit>();
    _addressController.addListener(_onChanged);
    _notesController.addListener(_onChanged);
    super.initState();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _pickupDateController.dispose();
    _returnDateController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    return BlocListener<SaleDetailCubit, SaleDetailState>(
      listener: (context, state) {
        if (state is SaleDetailLoaded) {
          context.pop(true);
          showSuccess(context, 'Venda atualizada com sucesso!');
          return;
        }
        if (state is SaleDetailError) {
          showError(context, 'Erro ao atualizar venda');
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
          appBar: AppBar(title: const Text('Editar venda')),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                children: [
                  CustomTextField(
                    controller: _addressController,
                    hintText: 'Endereço',
                    labelText: 'Endereço',
                    validators: [Required()],
                  ),
                  CustomTextField(
                    controller: _pickupDateController,
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _pickupDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.utc(2100),
                        locale: const Locale('pt', 'BR'),
                      );
                      if (selectedDate != null) {
                        _pickupDateController.text = selectedDate.toStringFixed;
                        setState(() {
                          _pickupDate = selectedDate;
                          _hasChanges = true;
                        });
                      }
                    },
                    hintText: 'Data retirada',
                    labelText: 'Data retirada',
                  ),
                  CustomTextField(
                    controller: _returnDateController,
                    onTap: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate:
                            _returnDate ?? _pickupDate ?? DateTime.now(),
                        firstDate: _pickupDate ?? DateTime(2020),
                        lastDate: DateTime.utc(2100),
                        locale: const Locale('pt', 'BR'),
                      );
                      if (selectedDate != null) {
                        _returnDateController.text = selectedDate.toStringFixed;
                        setState(() {
                          _returnDate = selectedDate;
                          _hasChanges = true;
                        });
                      }
                    },
                    hintText: 'Data devolução',
                    labelText: 'Data devolução',
                  ),
                  CustomTextField(
                    controller: _notesController,
                    hintText: 'Observações',
                    labelText: 'Observações',
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
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
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await _cubit.updateSaleDetails(
                        widget.sale.id,
                        address: _addressController.text.isEmpty
                            ? null
                            : _addressController.text,
                        pickupDate: _pickupDate,
                        returnDate: _returnDate,
                        notes: _notesController.text.isEmpty
                            ? null
                            : _notesController.text,
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
                CustomButton.outlined(
                  onPressed: _handleCancel,
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
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
