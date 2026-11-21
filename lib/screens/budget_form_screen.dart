import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pocket/controllers/app_controller.dart';

import '../models/budget.dart';
import '../models/category.dart';

class BudgetFormScreen extends StatefulWidget {
  const BudgetFormScreen({super.key});

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Budget? _existingBudget;

  // Guarda o id da categoria selecionada, e não o nome.
  int? _selectedCategoryId;

  bool _initialized = false;
  bool _newCategory = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Budget) {
      _existingBudget = arguments;

      _selectedCategoryId = arguments.category.id;
      _amountController.text = arguments.amount.toStringAsFixed(2);
      _descriptionController.text = arguments.description ?? '';
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<Category> _availableCategories(AppController app) {
    return app.categoriesOfType(CategoryType.expense)
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  double? _parseAmount(String value) {
    var normalized = value.trim().replaceAll(RegExp(r'[^\d.,]'), '');

    if (normalized.isEmpty) return null;

    // Aceita formatos como 250,50 ou 1.250,50.
    if (normalized.contains(',')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    }

    return double.tryParse(normalized);
  }

  Future<void> _saveBudget() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final amount = _parseAmount(_amountController.text);
    if (amount == null) return;

    final app = context.read<AppController>();

    setState(() => _isSaving = true);

    try {
      Category? category;

      if (_newCategory) {
        // Cria a categoria no banco (ou devolve a existente com o mesmo nome).
        category = await app.addCategory(
          name: _categoryController.text,
          type: CategoryType.expense,
        );
      } else {
        for (final item in app.categories) {
          if (item.id == _selectedCategoryId) {
            category = item;
            break;
          }
        }
      }

      if (!mounted) return;

      if (category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma categoria.')),
        );
        return;
      }

      final description = _descriptionController.text.trim();

      final budget = Budget(
        id: _existingBudget?.id ?? 0,
        category: category,
        amount: amount,
        description: description.isEmpty ? null : description,
      );

      Navigator.pop(context, budget);
    } catch (e) {
      debugPrint('Erro ao salvar orçamento: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o orçamento.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _selectExistingCategory(int? value) {
    setState(() {
      _selectedCategoryId = value;
      _categoryController.clear();
    });
  }

  void _toggleNewCategory() {
    setState(() {
      _newCategory = !_newCategory;
      _selectedCategoryId = null;
      _categoryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final categories = _availableCategories(app);

    final isEditing = _existingBudget != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar orçamento' : 'Novo orçamento',
          style: const TextStyle(
            color: Color(0xFF202124),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF202124)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Defina um limite de gastos para uma categoria.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),

                _buildSectionCard(
                  title: 'Dados do orçamento',
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    if (!_newCategory) ...[
                      const Text(
                        'Categoria',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value:
                            categories.any((c) => c.id == _selectedCategoryId)
                            ? _selectedCategoryId
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: 'Selecione uma categoria',
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: _selectExistingCategory,
                        validator: (value) =>
                            value == null ? 'Selecione uma categoria' : null,
                      ),
                    ],

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _toggleNewCategory,
                        icon: Icon(_newCategory ? Icons.list : Icons.add),
                        label: Text(
                          _newCategory
                              ? 'Selecionar categoria existente'
                              : 'Cadastrar nova categoria',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF28C76F),
                        ),
                      ),
                    ),

                    if (_newCategory) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _categoryController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nome da nova categoria *',
                          hintText: 'Ex.: Pets',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';

                          if (name.isEmpty) {
                            return 'Informe o nome da categoria';
                          }

                          final duplicate = categories.any(
                            (category) =>
                                category.name.toLowerCase() ==
                                name.toLowerCase(),
                          );

                          if (duplicate) {
                            return 'Essa categoria já existe';
                          }

                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Valor do orçamento *',
                        hintText: 'Ex.: 250,00',
                        prefixText: '${app.currency.currencySymbol} ',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                      validator: (value) {
                        final amount = _parseAmount(value ?? '');

                        if (amount == null) {
                          return 'Informe um valor válido';
                        }

                        if (amount <= 0) {
                          return 'O valor deve ser maior que zero';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        hintText: 'Detalhes sobre este orçamento',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveBudget,
                    icon: const Icon(Icons.check),
                    label: Text(
                      isEditing ? 'Salvar alterações' : 'Criar orçamento',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28C76F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: const Color(0xFF6B7280),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
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
                Icon(icon, color: const Color(0xFF28C76F)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
