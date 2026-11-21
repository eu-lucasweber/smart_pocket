import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pocket/controllers/app_controller.dart';
import 'package:smart_pocket/models/budgetException.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../widgets/bottom_navigation.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().load();
    });
  }

  double _spentFor(Budget budget, List<Transaction> transactions) {
    return transactions
        .where(
          (transaction) =>
              transaction.category.type == CategoryType.expense &&
              transaction.category.id == budget.category.id,
        )
        .fold<double>(0, (total, transaction) => total + transaction.value);
  }

  double _totalBudget(List<Budget> budgets) =>
      budgets.fold<double>(0, (total, b) => total + b.amount);

  double _totalSpent(List<Budget> budgets, List<Transaction> transactions) =>
      budgets.fold<double>(0, (total, b) => total + _spentFor(b, transactions));

  void _showError(Object error, String fallback) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is BudgetException ? error.message : fallback),
      ),
    );
  }

  Future<void> _openBudgetForm({Budget? budget}) async {
    final result = await Navigator.pushNamed(
      context,
      budget == null ? '/budgets/new' : '/budgets/edit',
      arguments: budget,
    );

    if (!mounted || result is! Budget) return;

    final app = context.read<AppController>();

    try {
      if (budget == null) {
        await app.addBudget(result);
      } else {
        await app.updateBudget(result);
      }
    } catch (e) {
      debugPrint('Erro ao salvar orçamento: $e');
      _showError(e, 'Não foi possível salvar o orçamento.');
    }
  }

  Future<void> _deleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir orçamento'),
        content: Text('Deseja excluir o orçamento de ${budget.category.name}?'),
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

    final app = context.read<AppController>();

    try {
      await app.deleteBudget(budget);
    } catch (e) {
      debugPrint('Erro ao excluir orçamento: $e');
      _showError(e, 'Não foi possível excluir o orçamento.');
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Orçamento excluído.')));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final budgets = app.budgets;
    final transactions = app.transactions;

    final totalBudget = _totalBudget(budgets);
    final totalSpent = _totalSpent(budgets, transactions);
    final available = totalBudget - totalSpent;

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
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),

              _buildSummaryCard(
                title: 'Orçamento total',
                value: app.currency.format(totalBudget),
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFF28C76F),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSmallSummaryCard(
                      title: 'Total gasto',
                      value: app.currency.format(totalSpent),
                      icon: Icons.trending_up,
                      iconColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallSummaryCard(
                      title: 'Disponível',
                      value: app.currency.format(available),
                      icon: Icons.savings_outlined,
                      iconColor: available < 0
                          ? Colors.red
                          : const Color(0xFF28C76F),
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

              if (budgets.isEmpty)
                _buildEmptyState()
              else
                ...budgets.map(
                  (budget) => _buildBudgetCard(budget, app, transactions),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
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

  Widget _buildBudgetCard(
    Budget budget,
    AppController app,
    List<Transaction> transactions,
  ) {
    final spent = _spentFor(budget, transactions);
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
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
            Text(
              'Orçamento: ${app.currency.format(budget.amount)}',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gasto',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
                Text(
                  app.currency.format(spent),
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
                        : 'Disponível: ${app.currency.format(remaining)}',
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Toque em "Novo" para criar seu primeiro orçamento.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
        ],
      ),
    );
  }
}