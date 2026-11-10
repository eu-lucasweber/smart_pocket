
import 'package:flutter/material.dart';
import 'package:smart_pocket/screens/edit_transaction_screen.dart';
import 'package:smart_pocket/screens/profile_screen.dart';

import 'database/database_helper.dart';
import 'screens/home_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/new_transaction_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/budget_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o banco de dados SQLite
  await DatabaseHelper.instance.database;

  runApp(const ControleFinanceiroApp());
}

class ControleFinanceiroApp extends StatelessWidget {
  const ControleFinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle Financeiro',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),

      initialRoute: '/painel',

      routes: {
        '/painel': (context) => const HomeScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/transactions/new': (context) => const NewTransactionScreen(),
        '/transactions/edit': (context) => const EditTransactionScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/budgets': (context) => const BudgetsScreen(),
        '/budgets/new': (context) => const BudgetFormScreen(),
        '/budgets/edit': (context) => const BudgetFormScreen(),
      },
    );
  }
}
