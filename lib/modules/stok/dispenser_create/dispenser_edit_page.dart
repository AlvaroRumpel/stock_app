import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/entities/product.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../dispenser_detail/cubit/dispenser_detail_cubit.dart';

class DispenserEditPage extends StatefulWidget {
  final Product dispenser;
  const DispenserEditPage({super.key, required this.dispenser});

  @override
  State<DispenserEditPage> createState() => _DispenserEditPageState();
}

class _DispenserEditPageState extends State<DispenserEditPage> with MessageMixin {
  final _formKey = GlobalKey<FormState>();
  late final _identifyController =
      TextEditingController(text: widget.dispenser.identifyNumber ?? '');
  late final _observationController =
      TextEditingController(text: widget.dispenser.observation ?? '');

  late final DispenserDetailCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<DispenserDetailCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _identifyController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DispenserDetailCubit, DispenserDetailState>(
      listener: (context, state) {
        if (state is DispenserDetailUpdated) {
          context.pop(true);
          showSuccess(context, 'Chopeira atualizada com sucesso!');
          return;
        }
        if (state is DispenserDetailError) {
          showError(context, 'Erro ao atualizar chopeira');
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Editar chopeira')),
        body: BlocSelector<DispenserDetailCubit, DispenserDetailState, bool>(
          selector: (state) => state is DispenserDetailLoading,
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
                      controller: _identifyController,
                      hintText: 'Identificação',
                      labelText: 'Identificação',
                      validators: [Required()],
                      keyboardType: TextInputType.text,
                    ),
                    CustomTextField(
                      controller: _observationController,
                      hintText: 'Observação',
                      labelText: 'Observação',
                      maxLines: 5,
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
                    final updated = widget.dispenser.copyWith(
                      identifyNumber: _identifyController.text,
                      observation: _observationController.text.isEmpty
                          ? null
                          : _observationController.text,
                    );
                    await _cubit.updateDispenser(updated);
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
