import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pocket/controllers/app_controller.dart';

import '../../models/category.dart';

class TransactionCategoryDropdown extends StatelessWidget {
  final Category? selectedCategory;
  final CategoryType categoryType;
  final ValueChanged<Category?> onCategoryChanged;

  const TransactionCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.categoryType,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final availableCategories = app.categoriesOfType(categoryType);

    Category? currentValue;
    for (final category in availableCategories) {
      if (category.id == selectedCategory?.id) {
        currentValue = category;
        break;
      }
    }

    return DropdownButtonFormField<Category>(
      value: currentValue,
      isExpanded: true,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
      ),
      hint: const Text('Selecione uma categoria'),
      items: availableCategories
          .map(
            (category) => DropdownMenuItem<Category>(
              value: category,
              child: Text(category.name),
            ),
          )
          .toList(),
      onChanged: onCategoryChanged,
      validator: (value) => value == null ? 'Selecione uma categoria' : null,
    );
  }
}
