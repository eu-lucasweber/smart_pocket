import 'package:flutter/material.dart';

// Type
import '../../models/category.dart';

class TransactionTypeSelector extends StatelessWidget {
  final CategoryType selectedType;
  final ValueChanged<CategoryType> onTypeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _typeButton(
            label: 'Receita',
            value: CategoryType.income,
            icon: Icons.arrow_downward,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _typeButton(
            label: 'Despesa',
            value: CategoryType.expense,
            icon: Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _typeButton({
    required String label,
    required CategoryType value,
    required IconData icon,
  }) {
    final selected = selectedType == value;

    return OutlinedButton.icon(
      onPressed: () {
        onTypeChanged(value);
      },
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? Colors.green.shade50
            : Colors.white,
        foregroundColor: selected
            ? Colors.green.shade700
            : Colors.grey.shade700,
        side: BorderSide(
          color: selected
              ? Colors.green.shade600
              : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
      ),
    );
  }
}