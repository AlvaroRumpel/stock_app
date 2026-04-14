import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../utils/app_assets.dart';

class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,

        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.attach_money),
            label: 'Vendas',
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              AppAssets.package2,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.darkPrimary300,
                BlendMode.srcIn,
              ),
            ),
            label: 'Estoque',
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Clientes',
          ),
        ],

        onDestinationSelected: _onTap,
      ),
    );
  }

  void _onTap(int index) {
    // For the stock tab (index 2), always reload from initial location so
    // the product list refreshes after sales or edits.
    final forceInitial = index == 2 || index == navigationShell.currentIndex;
    navigationShell.goBranch(index, initialLocation: forceInitial);
  }
}
