import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class CustomerCreatePage extends StatelessWidget {
  const CustomerCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Cliente')),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'preencha os dados para cadastrar o cliente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkPrimary300,
                ),
              ),
              _buildTextField('Nome'),
              _buildTextField('Celular'),
              _buildTextField('Endereço'),
              _buildTextField('Cidade'),
              _buildTextField('Observação'),
              const SizedBox(height: 24),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField(String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      style: const TextStyle(color: AppColors.darkPrimary300),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkPrimary300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkPrimary300,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator:
          (value) =>
              (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
    ),
  );
}

Widget _buildButtons(BuildContext context) {
  return Column(
    children: [
      SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightAvatar100,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: const Text(
            "Salvar",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 50,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            context.goNamed(RouteName.customers.name);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.darkPrimary300, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: const Text(
            "Cancelar",
            style: TextStyle(fontSize: 16, color: AppColors.darkPrimary300),
          ),
        ),
      ),
    ],
  );
}
