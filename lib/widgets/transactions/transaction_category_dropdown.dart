import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../mocks/category_mock.dart';

class TransactionCategoryDropdown extends StatelessWidget {
  final Category? selectedCategory;
  final CategoryType categoryType;
  final ValueChanged<Category?> onCategoryChanged;
  final List<Category>? categories;

  const TransactionCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.categoryType,
    required this.onCategoryChanged,
    this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final availableCategories = (categories ?? CategoryMock.categories)
        .where((category) => category.type == categoryType)
        .toList();

    return DropdownButtonFormField<Category>(
      value: selectedCategory,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
      ),
      hint: const Text('Selecione uma categoria'),
      items: availableCategories.map((category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: onCategoryChanged,
      validator: (value) {
        if (value == null) {
          return 'Selecione uma categoria';
        }
        return null;
      },
    );
  }
}