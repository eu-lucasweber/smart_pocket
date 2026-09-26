import '../models/category.dart';
import '../models/transaction.dart';

class TransactionMock {
  static final Category freelanceMock = Category(
    id: 7,
    name: 'Freelance',
    type: CategoryType.income,
  );

  static final Category transporteMock = Category(
    id: 2,
    name: 'Transporte',
    type: CategoryType.expense,
  );

  static final Category moradiaMock = Category(
    id: 3,
    name: 'Moradia',
    type: CategoryType.expense,
  );

  static final Category alimentacaoMock = Category(
    id: 1,
    name: 'Alimentação',
    type: CategoryType.expense,
  );

  static final List<Transaction> transactions = [
    Transaction(
      id: 1,
      description: 'Freelance de dev',
      category: freelanceMock,
      date: '24/08/2026',
      value: 950.00,
      type: CategoryType.income,
    ),
    Transaction(
      id: 2,
      description: 'Combustível',
      category: transporteMock,
      date: '23/08/2026',
      value: 580.00,
      type: CategoryType.expense,
    ),
    Transaction(
      id: 3,
      description: 'Aluguel',
      category: moradiaMock,
      date: '22/08/2026',
      value: 1050.00,
      type: CategoryType.expense,
    ),
    Transaction(
      id: 4,
      description: 'Supermercado',
      category: alimentacaoMock,
      date: '21/08/2026',
      value: 455.22,
      type: CategoryType.expense,
    ),
  ];
}