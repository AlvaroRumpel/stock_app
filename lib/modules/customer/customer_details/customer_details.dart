import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/utils/context_extensions.dart';

class CustomerDetails extends StatelessWidget {
  const CustomerDetails({super.key});

  @override
  Widget build(BuildContext context) {
    // final List<Map<String, String>> historicoCompras = [
    //   {
    //     'data': '23 Fev',
    //     'descricao': '2 X 30L – 1 X 50L | 1 X chopeira',
    //     'preco': 'R\$320,00',
    //   },
    //   {
    //     'data': '23 Fev',
    //     'descricao': '2 X 30L – 1 X 50L | 1 X chopeira',
    //     'preco': 'R\$320,00',
    //   },
    //   {
    //     'data': '23 Fev',
    //     'descricao': '2 X 30L – 1 X 50L | 1 X chopeira',
    //     'preco': 'R\$320,00',
    //   },
    //   {
    //     'data': '23 Fev',
    //     'descricao': '2 X 30L – 1 X 50L | 1 X chopeira',
    //     'preco': 'R\$320,00',
    //   },
    // ];

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.width,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBg200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ana Silva',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('(55) 91234-5678', style: TextStyle(fontSize: 16)),
                  Text(
                    'Rua Amazonas, 325, Centro',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Container(
            //   width: context.width,
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: AppColors.darkBg200,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'Históricos de compras',
            //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //       ),
            //       const SizedBox(height: 10),
            //       ListView.separated(
            //         shrinkWrap: true,
            //         itemCount: historicoCompras.length,
            //         physics: const NeverScrollableScrollPhysics(),
            //         itemBuilder: (context, index) {
            //           final purchase = historicoCompras[index];

            //           return Card(
            //             color: AppColors.darkBg100,
            //             margin: EdgeInsets.zero,
            //             child: ListTile(
            //               leading: CircleAvatar(
            //                 backgroundColor: AppColors.lightPrimary200,
            //                 child: Text(
            //                   purchase['data']!.split(' ')[0],
            //                   style: const TextStyle(
            //                     color: Colors.black,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ),
            //               title: Text(
            //                 purchase['descricao']!,
            //                 style: const TextStyle(
            //                   color: AppColors.darkText100,
            //                 ),
            //               ),
            //               subtitle: Text(
            //                 purchase['preco']!,
            //                 style: const TextStyle(
            //                   color: AppColors.darkText100,
            //                 ),
            //               ),
            //             ),
            //           );
            //         },
            //         separatorBuilder:
            //             (context, index) => const SizedBox(height: 8),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
