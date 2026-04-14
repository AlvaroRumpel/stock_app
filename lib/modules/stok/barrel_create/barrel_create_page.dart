import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/string_extensions.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'cubit/barrel_create_cubit.dart';

class BarrelCreatePage extends StatefulWidget {
  const BarrelCreatePage({super.key});

  @override
  State<BarrelCreatePage> createState() => _BarrelCreatePageState();
}

class _BarrelCreatePageState extends State<BarrelCreatePage> with MessageMixin {
  final _formKey = GlobalKey<FormState>();
  final _batchController = TextEditingController();
  final _qty30Controller = TextEditingController();
  final _qty50Controller = TextEditingController();
  final _costController = TextEditingController();
  final _sellController = TextEditingController();
  final _observationController = TextEditingController();
  DateTime? _expirationDate;
  final _expirationDateController = TextEditingController();

  late final BarrelCreateCubit _cubit;
  @override
  void initState() {
    _cubit = context.read<BarrelCreateCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BarrelCreateCubit, BarrelCreateState>(
      listener: (context, state) {
        if (state is BarrelCreateSuccess) {
          context.pop(true);
          showSuccess(context, 'Lote cadastrado com sucesso!');
          return;
        }

        if (state is BarrelCreateError) {
          showError(context, state.message ?? 'Erro ao cadastrar lote');
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Novo lote de barris')),
        body: BlocSelector<BarrelCreateCubit, BarrelCreateState, bool>(
          selector: (state) {
            return state is BarrelCreateLoading;
          },
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
                      suffix: InkWell(
                        child: const Icon(Icons.photo_camera_outlined),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => _CameraScan(
                                      onDetect:
                                          (value) =>
                                              _batchController.text = value,
                                    ),
                              ),
                            ),
                      ),
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
                          initialDate: _expirationDate,
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.utc(2100),
                          locale: const Locale('pt', 'BR'),
                        );

                        if (selectedDate != null) {
                          _expirationDateController.text =
                              selectedDate.toStringFixed;
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
                            inputFormatters: [
                              RealCurrencyInputFormatterNoSymbol(),
                            ],
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
                            inputFormatters: [
                              RealCurrencyInputFormatterNoSymbol(),
                            ],
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
                    final qty30 = int.tryParse(_qty30Controller.text) ?? 0;
                    final qty50 = int.tryParse(_qty50Controller.text) ?? 0;
                    if (qty30 <= 0 && qty50 <= 0) {
                      showError(
                        context,
                        'Informe a quantidade de ao menos um volume',
                      );
                      return;
                    }
                    await _cubit.createBarrel(
                      batchNumber: _batchController.text,
                      qty30l: _qty30Controller.text.isEmpty ? '0' : _qty30Controller.text,
                      qty50l: _qty50Controller.text.isEmpty ? '0' : _qty50Controller.text,
                      expirationDate: _expirationDate,
                      costPrice: _costController.text,
                      sellPrice: _sellController.text,
                      observation: _observationController.text,
                    );
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

class _CameraScan extends StatefulWidget {
  final void Function(String) onDetect;

  const _CameraScan({required this.onDetect});

  @override
  State<_CameraScan> createState() => _CameraScanState();
}

class _CameraScanState extends State<_CameraScan> with MessageMixin {
  bool _detected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aponte para o código de barras')),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_detected) return;
          if (capture.barcodes.isEmpty) return;
          final value = capture.barcodes.first.displayValue;
          if (value == null || value.isEmpty) return;
          _detected = true;
          widget.onDetect(value);
          await Future.delayed(Durations.medium4);
          if (context.mounted) {
            showSuccess(context, 'Código encontrado');
            context.pop();
          }
        },
      ),
    );
  }
}
