import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../shared/entities/product.dart';
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
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _sellController = TextEditingController();
  final _observationController = TextEditingController();
  DateTime? _expirationDate;
  final _expirationDateController = TextEditingController();
  final _volumeSelected = ValueNotifier(VolumeEnum.v30);

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
          showSuccess(context, 'Barril cadastrado com sucesso!');
          return;
        }

        if (state is BarrelCreateError) {
          showError(context, 'Erro ao cadastrar barril');
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Novo barril')),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Volume'),
                        ValueListenableBuilder(
                          valueListenable: _volumeSelected,
                          builder: (_, volumeSelected, child) {
                            return Row(
                              spacing: 4,
                              children: [
                                Row(
                                  children: [
                                    Radio<VolumeEnum>(
                                      value: VolumeEnum.v30,
                                      groupValue: volumeSelected,
                                      onChanged: (volume) {
                                        _volumeSelected.value =
                                            volume ?? volumeSelected;
                                      },
                                    ),
                                    const Text('30 litros'),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Radio<VolumeEnum>(
                                      value: VolumeEnum.v50,
                                      groupValue: volumeSelected,
                                      onChanged: (volume) {
                                        _volumeSelected.value =
                                            volume ?? volumeSelected;
                                      },
                                    ),
                                    const Text('50 litros'),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _quantityController,
                            hintText: 'Quantidade',
                            labelText: 'Quantidade',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validators: [Required()],
                          ),
                        ),
                        Expanded(
                          child: CustomTextField(
                            controller: _expirationDateController,
                            onTap: () async {
                              final selectedDate = await showDatePicker(
                                initialDate: _expirationDate,
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.utc(2100),
                              );

                              if (selectedDate != null) {
                                _expirationDateController.text =
                                    selectedDate.toStringFixed;
                                _expirationDate = selectedDate;
                              }
                            },
                            hintText: 'Validade',
                            labelText: 'Validade',
                            validators: [Required()],
                          ),
                        ),
                      ],
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
                    await _cubit.createBarrel(
                      batchNumber: _batchController.text,
                      volume: _volumeSelected.value,
                      quantity: _quantityController.text,
                      expirationDate: _expirationDate!,
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

class _CameraScan extends StatelessWidget with MessageMixin {
  final void Function(String) onDetect;

  const _CameraScan({required this.onDetect});
  @override
  Widget build(BuildContext context) {
    bool detected = false;
    return Scaffold(
      appBar: AppBar(),
      body: MobileScanner(
        onDetect: (capture) async {
          if (detected) return;
          onDetect(capture.barcodes.first.displayValue ?? '');
          detected = true;
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
