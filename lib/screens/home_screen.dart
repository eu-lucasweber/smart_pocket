
import 'package:flutter/material.dart';
import 'package:smart_pocket/models/transaction.dart';
import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/repositories/transaction_repository.dart';
import 'package:smart_pocket/widgets/home/transaction_card.dart';

import '../widgets/home/balance_card.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/home/category_chart.dart';
import '../widgets/home/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionRepository _transactionRepository =
      TransactionRepository();

  List<Transaction> _transactions = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _transactionRepository.getAll();

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar transações: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double total = _transactions.fold(
      0.0,
      (total, transaction) =>
          transaction.category.type == CategoryType.income
              ? total + transaction.value
              : total - transaction.value,
    );

    final String totalBalance =
        "R\$ ${total.toStringAsFixed(2)}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Painel',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Visão geral das suas finanças',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BalanceCard(value: totalBalance),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Receitas',
                            value: totalBalance,
                            icon: Icons.north_east,
                            iconColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Despesas',
                            value: totalBalance,
                            icon: Icons.south_east,
                            iconColor: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    CategoryChart(totalBalance: totalBalance),

                    const SizedBox(height: 14),

                    TransactionList(
                      transactions: _transactions,
                    ),
                  ],
                ),
              ),
      ),

      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }
}
