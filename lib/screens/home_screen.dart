import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pocket/controllers/app_controller.dart';
import 'package:smart_pocket/models/transaction.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    final String totalBalance = app.currency.format(app.balance);
    final String totalIncomeFormatted = app.currency.format(app.totalIncome);
    final String totalExpenseFormatted = app.currency.format(app.totalExpense);

    final bool isLoading = app.isLoading;
    final List<Transaction> transactions = app.transactions;

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
        child: isLoading
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
                            value: totalIncomeFormatted,
                            icon: Icons.north_east,
                            iconColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Despesas',
                            value: totalExpenseFormatted,
                            icon: Icons.south_east,
                            iconColor: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    CategoryChart(transactions: transactions),

                    const SizedBox(height: 14),

                    TransactionList(transactions: transactions),
                  ],
                ),
              ),
      ),

      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }
}
