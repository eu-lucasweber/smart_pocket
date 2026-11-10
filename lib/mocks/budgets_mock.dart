import 'package:smart_pocket/mocks/category_mock.dart';
import 'package:smart_pocket/models/category.dart';

import '../models/budget.dart';

class BudgetMock {
  static final List<Category> _categories = CategoryMock.categories;

  static final List<Budget> categories = [
    Budget(
      id: 1,
      category: _categories.firstWhere(
        (category) => category.name == 'Alimentação',
        orElse: () => _categories.first,
      ),
      amount: 600.00,
    ),
    Budget(
      id: 2,
      category: _categories.firstWhere(
        (category) => category.name == 'Transporte',
        orElse: () => _categories.first,
      ),
      amount: 300.00,
    ),
    Budget(
      id: 3,
      category: _categories.firstWhere(
        (category) => category.name == 'Moradia',
        orElse: () => _categories.first,
      ),
      amount: 1200.00,
    ),
  ];
}

 