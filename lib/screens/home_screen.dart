import 'package:flutter/material.dart';
import 'package:smart_pocket/mocks/transaction_mock.dart';
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
  final List<Transaction> _transactions = TransactionMock.transactions;
  String _totalBalance = "R\$ 2.765,75";

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceCard(value: _totalBalance),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Receitas',
                      value: _totalBalance,
                      icon: Icons.north_east,
                      iconColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Despesas',
                      value: _totalBalance,
                      icon: Icons.south_east,
                      iconColor: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              CategoryChart(totalBalance: _totalBalance),

              const SizedBox(height: 14),

              Expanded(child: TransactionList(transactions: _transactions)),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }
}
