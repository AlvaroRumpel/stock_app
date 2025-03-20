import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerInfo(name: "Vick", phone: "55 999271130"),
            CustomerInfo(name: "Jorge", phone: "40028922"),
          ],
        ),
      ),
    );
  }
}

class CustomerInfo extends StatelessWidget {
  const CustomerInfo({super.key, required this.name, required this.phone});

  final String name;
  final String phone;

  String getInitials(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : "?";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 408,
      padding: const EdgeInsets.only(top: 8, right: 24, bottom: 8, left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppColors.darkBg200,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.lightAvatar200,
            radius: 24,
            child: Text(
              getInitials(name),
              style: TextStyle(
                color: AppColors.lightAvatar100,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(name), const SizedBox(height: 4), Text(phone)],
          ),
        ],
      ),
    );
  }
}
