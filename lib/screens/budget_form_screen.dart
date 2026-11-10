import 'package:flutter/material.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../mocks/category_mock.dart';

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

  String? _selectedCategory;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _initialized = false;

  final List<String> _months = const [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Budget) {
      _existingBudget = arguments;

      _selectedCategory = arguments.category.name;
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

  List<String> get _availableCategories {
    final categories = CategoryMock.categories
        .where((category) => category.type == CategoryType.expense)
        .map((category) => category.name)
        .toSet()
        .toList();

    // Inclui a categoria selecionada mesmo que tenha sido criada
    // durante esta sessão e ainda não esteja no mock.
    if (_selectedCategory != null &&
        !categories.contains(_selectedCategory)) {
      categories.add(_selectedCategory!);
    }

    categories.sort();
    return categories;
  }

  double? _parseAmount(String value) {
    var normalized = value.trim().replaceAll('R\$', '').replaceAll(' ', '');

    if (normalized.isEmpty) return null;

    // Aceita formatos como 250,50 ou 1.250,50.
    if (normalized.contains(',')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    }

    return double.tryParse(normalized);
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) return;
    List<Category> _categories = CategoryMock.categories;
    final category_id = (_selectedCategory ?? _categoryController.text).trim();
    final amount = _parseAmount(_amountController.text);

    final category = _categories.firstWhere(
        (category) => category.id == category_id,
        orElse: () => _categories.first,
      );

    if (category == null || amount == null) return;

    final budget = Budget(
      id: _existingBudget?.id ?? 0,
      category: category,
      amount: amount,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    Navigator.pop(context, budget);
  }

  void _selectExistingCategory(String? value) {
    setState(() {
      _selectedCategory = value;
      _categoryController.clear();
    });
  }

  void _useNewCategory() {
    setState(() {
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionCard(
                  title: 'Dados do orçamento',
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    const Text(
                      'Categoria existente',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _availableCategories.contains(_selectedCategory)
                          ? _selectedCategory
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Selecione uma categoria',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableCategories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: _selectExistingCategory,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _useNewCategory,
                        icon: const Icon(Icons.add),
                        label: const Text('Cadastrar nova categoria'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF28C76F),
                        ),
                      ),
                    ),

                    if (_selectedCategory == null) ...[
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
                          if (_selectedCategory != null) return null;

                          final name = value?.trim() ?? '';

                          if (name.isEmpty) {
                            return 'Informe o nome da categoria';
                          }

                          final duplicate = CategoryMock.categories.any(
                            (category) =>
                                category.type == CategoryType.expense &&
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Valor do orçamento *',
                        hintText: 'Ex.: 250,00',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payments_outlined),
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

                _buildSectionCard(
                  title: 'Período',
                  icon: Icons.calendar_month_outlined,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Mês',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(_months[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedMonth = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Ano',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        6,
                        (index) {
                          final year = DateTime.now().year + index - 2;

                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        },
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedYear = value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveBudget,
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