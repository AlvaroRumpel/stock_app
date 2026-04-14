import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/entities/product.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../barrel_detail/cubit/barrel_detail_cubit.dart';

class BarrelEditPage extends StatefulWidget {
  final Product barrel;
  const BarrelEditPage({super.key, required this.barrel});

  @override
  State<BarrelEditPage> createState() => _BarrelEditPageState();
}

class _BarrelEditPageState extends State<BarrelEditPage> with MessageMixin {
  final _formKey = GlobalKey<FormState>();
  late final _batchController =
      TextEditingController(text: widget.barrel.batchNumber ?? '');
  late final _qty30Controller =
      TextEditingController(text: (widget.barrel.qty30l ?? 0).toString());
  late final _qty50Controller =
      TextEditingController(text: (widget.barrel.qty50l ?? 0).toString());
  late final _costController = TextEditingController(
    text: widget.barrel.costPrice?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
  );
  late final _sellController = TextEditingController(
    text: widget.barrel.salePrice?.toStringAsFixed(2).replaceAll('.', ',') ?? '',
  );
  late final _observationController =
      TextEditingController(text: widget.barrel.observation ?? '');
  late DateTime? _expirationDate = widget.barrel.expirationDate;
  late final _expirationDateController =
      TextEditingController(text: widget.barrel.expirationDate?.toStringFixed ?? '');

  late final BarrelDetailCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<BarrelDetailCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _batchController.dispose();
    _qty30Controller.dispose();
    _qty50Controller.dispose();
    _costController.dispose();
    _sellController.dispose();
    _observationController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BarrelDetailCubit, BarrelDetailState>(
      listener: (context, state) {
        if (state is BarrelDetailUpdated) {
          context.pop(true);
          showSuccess(context, 'Barril atualizado com sucesso!');
          return;
        }
        if (state is BarrelDetailError) {
          showError(context, 'Erro ao atualizar barril');
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Editar barril')),
        body: BlocSelector<BarrelDetailCubit, BarrelDetailState, bool>(
          selector: (state) => state is BarrelDetailLoading,
          builder: (context, isLoading) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 16,
                  children: [
                    CustomTextField(
                      controller: _batchController,
                      hintText: 'Número do lote',
                      labelText: 'Número do lote',
                      validators: [Required()],
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _qty30Controller,
                            hintText: '0',
                            labelText: 'Qtd. 30L',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        Expanded(
                          child: CustomTextField(
                            controller: _qty50Controller,
                            hintText: '0',
                            labelText: 'Qtd. 50L',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: _expirationDateController,
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _expirationDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.utc(2100),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (selectedDate != null) {
                          _expirationDateController.text = selectedDate.toStringFixed;
                          _expirationDate = selectedDate;
                        }
                      },
                      hintText: 'Validade (opcional)',
                      labelText: 'Validade',
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _costController,
                            hintText: '0,00',
                            labelText: 'Preço de custo',
                            prefix: const Text('R\$ '),
                            keyboardType: TextInputType.number,
                            inputFormatters: [RealCurrencyInputFormatterNoSymbol()],
                            validators: [Required()],
                          ),
                        ),
                        Expanded(
                          child: CustomTextField(
                            controller: _sellController,
                            hintText: '0,00',
                            labelText: 'Preço de venda',
                            prefix: const Text('R\$ '),
                            keyboardType: TextInputType.number,
                            inputFormatters: [RealCurrencyInputFormatterNoSymbol()],
                            validators: [Required()],
                          ),
                        ),
                      ],
                    ),
                    CustomTextField(
                      controller: _observationController,
                      hintText: 'Observação',
                      labelText: 'Observação',
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            );
          },
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
                    final updated = widget.barrel.copyWith(
                      batchNumber: _batchController.text,
                      qty30l: int.tryParse(_qty30Controller.text) ?? 0,
                      qty50l: int.tryParse(_qty50Controller.text) ?? 0,
                      expirationDate: _expirationDate,
                      costPrice: double.tryParse(
                        _costController.text.toCurrencyFixed,
                      ),
                      salePrice: double.tryParse(
                        _sellController.text.toCurrencyFixed,
                      ),
                      observation: _observationController.text.isEmpty
                          ? null
                          : _observationController.text,
                    );
                    await _cubit.updateBarrel(updated);
                  }
                },
                child: const Text('Salvar'),
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
