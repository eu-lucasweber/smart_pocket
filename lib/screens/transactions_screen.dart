import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pocket/controllers/app_controller.dart';
import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/models/transaction.dart';

import '../widgets/bottom_navigation.dart';
import '../widgets/transactions/transaction_filters.dart';
import '../widgets/transactions/transaction_list.dart';
import '../widgets/transactions/transaction_search.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'Todos';

  List<Transaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
    final search = _searchController.text.trim().toLowerCase();

    return _transactions.where((transaction) {
      final matchesSearch =
          transaction.description.toLowerCase().contains(search) ||
          transaction.category.name.toLowerCase().contains(search);

      final matchesFilter =
          _selectedFilter == 'Todos' ||
          (_selectedFilter == 'Receita' &&
              transaction.category.type == CategoryType.income) ||
          (_selectedFilter == 'Despesa' &&
              transaction.category.type == CategoryType.expense);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    _transactions = app.transactions;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transações',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 3),

            Text(
              '5 lançamentos',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _newTransaction,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF00A875),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text(
                'Nova',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              children: [
                TransactionSearch(
                  controller: _searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 10),

                TransactionFilters(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: TransactionList(
              transactions: _filteredTransactions,
              onEdit: _editTransaction,
              onDelete: _deleteTransaction,
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
    );
  }

  Future<void> _newTransaction() async {
    final result = await Navigator.pushNamed(context, '/transactions/new');

    if (!mounted) return;

    if (result == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppController>().load();
      });
    }
  }

  Future<void> _editTransaction(Transaction transaction) async {
    final result = await Navigator.pushNamed(
      context,
      '/transactions/edit',
      arguments: transaction,
    );

    if (!mounted) return;

    if (result == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppController>().load();
      });
    }
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final app = context.read<AppController>();

    try {
      await app.deleteTransaction(transaction);
    } catch (e) {
      debugPrint('Erro ao excluir transação: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir a transação.')),
      );
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${transaction.description} removido.')),
    );
  }
}
