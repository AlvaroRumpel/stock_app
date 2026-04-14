import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'cubit/dispenser_create_cubit.dart';

class DispenserCreatePage extends StatefulWidget {
  const DispenserCreatePage({super.key});

  @override
  State<DispenserCreatePage> createState() => _DispenserCreatePageState();
}

class _DispenserCreatePageState extends State<DispenserCreatePage>
    with MessageMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifyController = TextEditingController();
  final _observationController = TextEditingController();

  late final DispenserCreateCubit _cubit;
  @override
  void initState() {
    _cubit = context.read<DispenserCreateCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DispenserCreateCubit, DispenserCreateState>(
      listener: (context, state) {
        if (state is BarrelCreateSuccess) {
          context.pop(true);
          showSuccess(context, 'Chopeira cadastrada com sucesso!');
          return;
        }

        if (state is BarrelCreateError) {
          showError(context, 'Erro ao cadastrar chopeira');
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nova chopeira')),
        body: BlocSelector<DispenserCreateCubit, DispenserCreateState, bool>(
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
                    await _cubit.createDispenser(
                      identify: _identifyController.text,
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
