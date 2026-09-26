import 'package:flutter/material.dart';
import 'package:smart_pocket/models/category.dart';

class TransactionItem extends StatelessWidget {
  final String description;
  final String categoryName;
  final String date;
  final double value;
  final CategoryType type;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.description,
    required this.categoryName,
    required this.date,
    required this.value,
    required this.type,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == CategoryType.income;

    final formattedValue = value
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return SizedBox(
      height: 76,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$categoryName • $date',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${isIncome ? '+' : '-'} R\$ $formattedValue',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isIncome
                  ? const Color(0xFF00A875)
                  : Colors.red,
            ),
          ),

          const SizedBox(width: 12),

          IconButton(
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.edit,
              size: 15,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 12),

          IconButton(
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.delete_outline,
              size: 15,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}