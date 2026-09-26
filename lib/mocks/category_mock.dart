import '../models/category.dart';

class CategoryMock {
  static final List<Category> categories = [
    Category(
      id: 1,
      name: 'Alimentação',
      type: CategoryType.expense,
    ),
    Category(
      id: 2,
      name: 'Transporte',
      type: CategoryType.expense,
    ),
    Category(
      id: 3,
      name: 'Moradia',
      type: CategoryType.expense,
    ),
    Category(
      id: 4,
      name: 'Lazer',
      type: CategoryType.expense,
    ),
    Category(
      id: 5,
      name: 'Saúde',
      type: CategoryType.expense,
    ),
    Category(
      id: 6,
      name: 'Salário',
      type: CategoryType.income,
    ),
    Category(
      id: 7,
      name: 'Freelance',
      type: CategoryType.income,
    ),
  ];
}