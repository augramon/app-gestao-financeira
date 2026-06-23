import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/expandable_tabs.dart';

/// Casca da navegação principal com barra inferior de 4 abas.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ExpandableTabs(
        selectedIndex: navigationShell.currentIndex,
        onChanged: _onTap,
        tabs: const [
          ExpandableTabItem(icon: Icons.home_rounded, label: 'Início'),
          ExpandableTabItem(icon: Icons.receipt_long_rounded, label: 'Gastos'),
          ExpandableTabItem(icon: Icons.category_rounded, label: 'Categorias'),
          ExpandableTabItem(icon: Icons.person_rounded, label: 'Perfil'),
        ],
      ),
    );
  }
}
