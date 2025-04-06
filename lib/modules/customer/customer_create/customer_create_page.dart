import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/utils/message_mixin.dart';
import '../../../shared/utils/validation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'cubit/customer_create_cubit.dart';

class CustomerCreatePage extends StatefulWidget {
  const CustomerCreatePage({super.key});

  @override
  State<CustomerCreatePage> createState() => _CustomerCreatePageState();
}

class _CustomerCreatePageState extends State<CustomerCreatePage>
    with MessageMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _observationController = TextEditingController();

  late final CustomerCreateCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<CustomerCreateCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerCreateCubit, CustomerCreateState>(
      listener: (context, state) {
        if (state is CustomerCreateSuccessCreate) {
          context.pop(true);
          showSuccess(context, 'Cliente cadastrado com sucesso!');
          return;
        }

        if (state is CustomerCreateError) {
          showError(context, 'Erro ao cadastrar cliente');
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Novo Cliente')),
        body: BlocSelector<CustomerCreateCubit, CustomerCreateState, bool>(
          selector: (state) => state is CustomerCreateLoading,
          builder: (context, isLoading) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 24,
                  children: [
                    const Text(
                      'Preencha os dados para cadastrar o cliente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkPrimary300,
                      ),
                    ),
                    Column(
                      spacing: 16,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Nome',
                          labelText: 'Nome',
                          validators: [Required()],
                        ),
                        CustomTextField(
                          controller: _phoneController,
                          hintText: 'Celular',
                          labelText: 'Celular',
                          validators: [Required()],
                        ),
                        CustomTextField(
                          controller: _addressController,
                          hintText: 'Endereço',
                          labelText: 'Endereço',
                        ),
                        CustomTextField(
                          controller: _cityController,
                          hintText: 'Cidade',
                          labelText: 'Cidade',
                        ),
                        CustomTextField(
                          controller: _observationController,
                          hintText: 'Observaçào',
                          labelText: 'Observação',
                          maxLines: 4,
                        ),
                      ],
                    ),
                    Column(
                      spacing: 16,
                      children: [
                        CustomButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await _cubit.createCustomer(
                                name: _nameController.text,
                                phone: _phoneController.text,
                                address: _addressController.text,
                                cityId: _cityController.text,
                                observation: _observationController.text,
                              );
                            }
                          },
                          child: const Text('Salvar'),
                        ),
                        CustomButton.outlined(
                          onPressed: () {
                            context.goNamed(RouteName.customers.name);
                          },
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
