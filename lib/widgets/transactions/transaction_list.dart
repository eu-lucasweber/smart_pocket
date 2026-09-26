import 'package:flutter/material.dart';
import 'package:smart_pocket/models/transaction.dart';
import 'transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;

  final void Function(Transaction transaction) onEdit;
  final void Function(Transaction transaction) onDelete;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
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

                return TransactionItem(
                  description: transaction.description,
                  categoryName: transaction.category.name,
                  date: transaction.date,
                  value: transaction.value,
                  type: transaction.type,
                  onEdit: () => onEdit(transaction),
                  onDelete: () => onDelete(transaction),
                );
              },
            ),
    );
  }
}