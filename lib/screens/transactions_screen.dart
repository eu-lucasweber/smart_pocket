import 'package:flutter/material.dart';
import 'package:smart_pocket/mocks/category_mock.dart';
import 'package:smart_pocket/mocks/transaction_mock.dart';
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

  final List<Transaction> _transactions = TransactionMock.transactions;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
  final search = _searchController.text.toLowerCase();

  return _transactions.where((transaction) {
    String categoryTemp = "";

    final index = CategoryMock.categories.indexWhere(
      (category) => category.id == transaction.category.id
    );

    if (index != -1) {
      categoryTemp = CategoryMock.categories[index].name;
    }

    final matchesSearch =
        transaction.description.toLowerCase().contains(search) ||
        categoryTemp.toLowerCase().contains(search);

    final matchesFilter =
        _selectedFilter == 'Todos' ||
        (_selectedFilter == 'Receita' &&
            transaction.type == CategoryType.income) ||
        (_selectedFilter == 'Despesa' &&
            transaction.type == CategoryType.expense);

    return matchesSearch && matchesFilter;
  }).toList();
}

  @override
  Widget build(BuildContext context) {
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

  void _newTransaction() {
    Navigator.pushNamed(context, '/transactions/new');
  }

  void _editTransaction(Transaction transaction) {
    Navigator.pushNamed(context, '/transactions/edit', arguments: transaction);
  }

  void _deleteTransaction(Transaction transaction) {

    setState(() {
      _transactions.removeAt(0);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${transaction.description} removido.')),
    );
  }
}
