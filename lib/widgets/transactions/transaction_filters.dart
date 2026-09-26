import 'package:flutter/material.dart';

class TransactionFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const TransactionFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterButton(
            label: 'Todos',
            selected: selectedFilter == 'Todos',
            onTap: () => onFilterChanged('Todos'),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _FilterButton(
            label: 'Receita',
            selected: selectedFilter == 'Receita',
            onTap: () => onFilterChanged('Receita'),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _FilterButton(
            label: 'Despesa',
            selected: selectedFilter == 'Despesa',
            onTap: () => onFilterChanged('Despesa'),
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF00A875)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? const Color(0xFF00A875)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: selected
                ? Colors.white
                : Colors.grey.shade600,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}