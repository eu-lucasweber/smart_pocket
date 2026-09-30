import 'package:flutter/material.dart';
import 'package:smart_pocket/models/transaction.dart';
import 'package:smart_pocket/widgets/home/home_transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: transactions.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma transação encontrada.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              itemCount: transactions.length,
              separatorBuilder: (_, __) {
                return Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                );
              },
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return TransactionItem (
                  description: transaction.description,
                  categoryName: transaction.category.name,
                  date: transaction.date,
                  value: transaction.value,
                  type: transaction.type
                );
              },
            ),
    );
  }
}