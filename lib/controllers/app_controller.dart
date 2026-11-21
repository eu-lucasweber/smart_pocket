import 'package:flutter/foundation.dart' hide Category;
import 'package:intl/intl.dart';
import 'package:smart_pocket/models/budget.dart';
import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/models/transaction.dart';
import 'package:smart_pocket/models/user_profile.dart';
import 'package:smart_pocket/repositories/budget_repository.dart';
import 'package:smart_pocket/repositories/category_repository.dart';
import 'package:smart_pocket/repositories/transaction_repository.dart';
import 'package:smart_pocket/repositories/user_profile_repository.dart';

class AppController extends ChangeNotifier {
  AppController({
    UserProfileRepository? userProfileRepository,
    TransactionRepository? transactionRepository,
    CategoryRepository? categoryRepository,
    BudgetRepository? budgetRepository,
  }) : _userProfileRepository =
           userProfileRepository ?? UserProfileRepository(),
       _transactionRepository =
           transactionRepository ?? TransactionRepository(),
       _categoryRepository = categoryRepository ?? CategoryRepository(),
       _budgetRepository = budgetRepository ?? BudgetRepository();

  final UserProfileRepository _userProfileRepository;
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository;

  UserProfile? _userProfile;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  List<Budget> _budgets = [];
  bool _isLoading = true;

  UserProfile? get userProfile => _userProfile;
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Category> get category => List.unmodifiable(_categories);
  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;

  String? _currencyCode;
  NumberFormat? _currencyFormat;

  NumberFormat get currency {
    final code = _userProfile?.currency ?? 'BRL';
    if (_currencyFormat == null || _currencyCode != code) {
      _currencyCode = code;
      _currencyFormat = NumberFormat.simpleCurrency(
        locale: 'pt_BR',
        name: code,
      );
    }
    return _currencyFormat!;
  }

  double get totalIncome => _sum(CategoryType.income);
  double get totalExpense => _sum(CategoryType.expense);
  double get balance => totalIncome - totalExpense;

  double _sum(CategoryType type) => _transactions
      .where((t) => t.category.type == type)
      .fold(0.0, (sum, t) => sum + t.value);

  Future<void> load({DateTime? month}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ref = month ?? DateTime.now();

      final (profile, transactions, categories, budget) = await (
        _userProfileRepository.getUserProfile(),
        _transactionRepository.getAllByMonth(month: ref.month, year: ref.year),
        _categoryRepository.getAll(),
        _budgetRepository.getAll(),
      ).wait;

      _userProfile = profile;
      _transactions = transactions;
      _categories = categories;
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await _transactionRepository.delete(transaction.id);

    _transactions.removeWhere((t) => t.id == transaction.id);
    notifyListeners();
  }

  List<Category> get categories => List.unmodifiable(_categories);

  List<Category> categoriesOfType(CategoryType type) =>
      _categories.where((c) => c.type == type).toList();

  Future<Category> addCategory({
    required String name,
    required CategoryType type,
  }) async {
    final trimmed = name.trim();

    final existing = await _categoryRepository.getByNameAndType(
      name: trimmed,
      type: type,
    );
    if (existing != null) return existing;

    final saved = await _categoryRepository.insert(name: trimmed, type: type);

    _categories.add(saved);
    _categories.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();

    return saved;
  }

  Future<void> addBudget(Budget budget) async {
    final id = await _budgetRepository.insert(budget);

    _budgets.add(
      Budget(
        id: id,
        category: budget.category,
        amount: budget.amount,
        description: budget.description,
      ),
    );
    notifyListeners();
  }

  Future<void> updateBudget(Budget budget) async {
    await _budgetRepository.update(budget);

    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) _budgets[index] = budget;
    notifyListeners();
  }

  Future<void> deleteBudget(Budget budget) async {
    await _budgetRepository.delete(budget.id);

    _budgets.removeWhere((b) => b.id == budget.id);
    notifyListeners();
  }
}
