import 'package:flutter/material.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../mocks/budgets_mock.dart';
import '../mocks/transaction_mock.dart';
import '../widgets/bottom_navigation.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final List<Budget> _budgets = BudgetMock.categories;

  late List<Transaction> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = [...TransactionMock.transactions];
  }

  double _spentFor(Budget budget) {
    return _transactions
        .where(
          (transaction) =>
              transaction.category.type == CategoryType.expense &&
              transaction.category == budget.category
        )
        .fold<double>(
          0,
          (total, transaction) => total + transaction.value,
        );
  }

  double get _totalBudget {
    return _budgets.fold<double>(
      0,
      (total, budget) => total + budget.amount,
    );
  }

  double get _totalSpent {
    return _budgets.fold<double>(
      0,
      (total, budget) => total + _spentFor(budget),
    );
  }

  double get _available {
    return _totalBudget - _totalSpent;
  }

  String _formatCurrency(double value) {
    final formatted = value.abs().toStringAsFixed(2).replaceAll('.', ',');
    final parts = formatted.split(',');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return '${value < 0 ? '-R\$ ' : 'R\$ '}$integerPart,${parts[1]}';
  }

  Future<void> _openBudgetForm({Budget? budget}) async {
    final result = await Navigator.pushNamed(
      context,
      budget == null ? '/budgets/new' : '/budgets/edit',
      arguments: budget,
    );

    if (!mounted || result is! Budget) return;

    setState(() {
      if (budget == null) {
        final newId = _budgets.isEmpty
            ? 1
            : _budgets
                    .map((item) => item.id)
                    .reduce((a, b) => a > b ? a : b) +
                1;

        _budgets.add(
          Budget(
            id: newId,
            category: result.category,
            amount: result.amount,
            description: result.description,
          ),
        );
      } else {
        final index = _budgets.indexWhere((item) => item.id == budget.id);

        if (index != -1) {
          _budgets[index] = Budget(
            id: budget.id,
            category: result.category,
            amount: result.amount,
            description: result.description,
          );
        }
      }
    });
  }

  Future<void> _deleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir orçamento'),
        content: Text(
          'Deseja excluir o orçamento de ${budget.category}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _budgets.removeWhere((item) => item.id == budget.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Orçamento excluído.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Orçamentos',
          style: TextStyle(
            color: Color(0xFF202124),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Controle seus gastos por categoria',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),

              _buildSummaryCard(
                title: 'Orçamento total',
                value: _formatCurrency(_totalBudget),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFF28C76F),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSmallSummaryCard(
                      title: 'Total gasto',
                      value: _formatCurrency(_totalSpent),
                      icon: Icons.trending_up,
                      iconColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallSummaryCard(
                      title: 'Disponível',
                      value: _formatCurrency(_available),
                      icon: Icons.savings_outlined,
                      iconColor:
                          _available < 0 ? Colors.red : const Color(0xFF28C76F),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Orçamentos por categoria',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF202124),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openBudgetForm(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Novo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28C76F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_budgets.isEmpty)
                _buildEmptyState()
              else
                ..._budgets.map(_buildBudgetCard),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 3,
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.12),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF202124),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final spent = _spentFor(budget);
    final remaining = budget.amount - spent;
    final progress = budget.amount <= 0 ? 0.0 : spent / budget.amount;
    final isOverBudget = spent > budget.amount;

    final progressColor = isOverBudget
        ? Colors.red
        : progress >= 0.8
            ? Colors.orange
            : const Color(0xFF28C76F);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    budget.category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202124),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openBudgetForm(budget: budget);
                    } else if (value == 'delete') {
                      _deleteBudget(budget);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'Orçamento: ${_formatCurrency(budget.amount)}',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gasto',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
                Text(
                  _formatCurrency(spent),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: const Color(0xFFE9ECEF),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isOverBudget
                        ? 'Acima do orçamento'
                        : 'Disponível: ${_formatCurrency(remaining)}',
                    style: TextStyle(
                      color: isOverBudget
                          ? Colors.red
                          : const Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: isOverBudget
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 44,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 12),
          Text(
            'Nenhum orçamento cadastrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Toque em "Novo" para criar seu primeiro orçamento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}