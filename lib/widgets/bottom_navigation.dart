import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _onDestinationSelected(
    BuildContext context,
    int index,
  ) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/painel');
        break;

      case 1:
        Navigator.pushReplacementNamed(context, '/transactions');
        break;

      // Futuramente:
      // case 2:
      //   Navigator.pushReplacementNamed(context, '/relatorios');
      //   break;

      // case 3:
      //   Navigator.pushReplacementNamed(context, '/perfil');
      //   break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,

      onDestinationSelected: (index) {
        _onDestinationSelected(context, index);
      },

      backgroundColor: Colors.white,
      indicatorColor: Colors.grey.shade200,

      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Painel',
        ),
        NavigationDestination(
          icon: Icon(Icons.format_list_bulleted),
          selectedIcon: Icon(Icons.format_list_bulleted),
          label: 'Transações',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Relatórios',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle_outlined),
          selectedIcon: Icon(Icons.account_circle),
          label: 'Perfil',
        ),
      ],
    );
  }
}
