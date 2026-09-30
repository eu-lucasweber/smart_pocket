import 'package:flutter/material.dart';
import 'package:smart_pocket/models/category.dart';

class TransactionItem extends StatelessWidget {
  final String description;
  final String categoryName;
  final String date;
  final double value;
  final CategoryType type;


  const TransactionItem({
    super.key,
    required this.description,
    required this.categoryName,
    required this.date,
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == CategoryType.income;
    final formattedValue = value
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              size: 17,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$categoryName • $date',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${isIncome ? '+' : '-'} R\$ $formattedValue',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}