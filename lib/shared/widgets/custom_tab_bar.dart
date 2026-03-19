import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;
  final List<Widget> _tabs;

  CustomTabBar({super.key, required this.tabController, required this.tabs})
    : _tabs = tabs.map((e) => Text(e)).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkPrimary100,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(1),
      child: TabBar(controller: tabController, tabs: _tabs),
    );
  }
}
