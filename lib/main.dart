import 'package:flutter/material.dart';
import 'package:smart_pocket/screens/edit_transaction_screen.dart';
import 'screens/home_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/new_transaction_screen.dart';

void main() {
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
        //'/': (context) => const SplashScreen(),
        //'/login': (context) => const LoginScreen(),
        '/painel': (context) => const HomeScreen(),
        '/transactions': (context) => const TransactionsScreen(),
        '/transactions/new': (context) => const NewTransactionScreen(),
        '/transactions/edit': (context) => const EditTransactionScreen(),
        //'/reports': (context) => const ReportsScreen(),
        //'/profile': (context) => const ProfileScreen(),
        
      },
    );
  }
}
