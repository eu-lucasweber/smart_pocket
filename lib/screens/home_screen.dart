import 'package:flutter/material.dart';

import '../widgets/home/balance_card.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/home/category_chart.dart';
import '../widgets/home/summary_card.dart';
import '../widgets/home/home_transaction_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
              const BalanceCard(value: 'R\$ 2.765,75'),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Receitas',
                      value: 'R\$ 2.765,75',
                      icon: Icons.north_east,
                      iconColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      title: 'Despesas',
                      value: 'R\$ 2.765,75',
                      icon: Icons.south_east,
                      iconColor: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const CategoryChart(),

              const SizedBox(height: 14),

              _buildTransactionsCard(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }

  Widget _buildTransactionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Últimos lançamentos',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          const TransactionItem(
            description: 'Freelance de dev',
            category: 'Trabalho',
            date: '24/09/2026',
            value: '+ R\$ 850,00',
            isIncome: true,
          ),

          const Divider(height: 1),

          const TransactionItem(
            description: 'Combustível',
            category: 'Transporte',
            date: '23/09/2026',
            value: '- R\$ 500,00',
            isIncome: false,
          ),

          const Divider(height: 1),

          const TransactionItem(
            description: 'Aluguel',
            category: 'Moradia',
            date: '22/09/2026',
            value: '- R\$ 1.050,00',
            isIncome: false,
          ),

          const Divider(height: 1),

          const TransactionItem(
            description: 'Supermercado',
            category: 'Alimentação',
            date: '21/09/2026',
            value: '- R\$ 455,22',
            isIncome: false,
          ),
        ],
      ),
    );
  }
}
