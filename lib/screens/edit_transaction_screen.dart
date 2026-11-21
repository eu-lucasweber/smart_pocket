import 'package:flutter/material.dart';

import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/models/transaction.dart';
import 'package:smart_pocket/repositories/transaction_repository.dart';
import 'package:smart_pocket/repositories/category_repository.dart';

import 'package:smart_pocket/widgets/transactions/transaction_category_dropdown.dart';
import 'package:smart_pocket/widgets/transactions/transaction_description_textform.dart';
import 'package:smart_pocket/widgets/transactions/transaction_save_sizedbox.dart';
import 'package:smart_pocket/widgets/transactions/transaction_value_textform.dart';
import 'package:smart_pocket/widgets/transactions/transaction_type_selector.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  late Transaction _transaction;

  CategoryType _type = CategoryType.expense;
  Category? _category;

  bool _isInit = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      _transaction = ModalRoute.of(context)!.settings.arguments as Transaction;

      _descriptionController.text = _transaction.description;

      _valueController.text = _transaction.value
          .toStringAsFixed(2)
          .replaceAll('.', ',');

      _type = _transaction.category.type;

      _isInit = false;

      _loadCategory();
    }
  }

  Future<void> _loadCategory() async {
    try {
      final category = await _categoryRepository.getByNameAndType(
        name: _transaction.category.name,
        type: _transaction.category.type,
      );

      if (!mounted) return;

      setState(() {
        _category = category;
        _type = category?.type ?? _transaction.category.type;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar categoria: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text(
          'Editar transação',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF28C76F)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar lançamento',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Altere as informações da sua transação.',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),

                    const SizedBox(height: 24),

                    // TIPO
                    const Text(
                      'Tipo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TransactionTypeSelector(
                      selectedType: _type,
                      onTypeChanged: (type) {
                        setState(() {
                          _type = type;
                          _category = null;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // DESCRIÇÃO
                    const Text(
                      'Descrição',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TransactionDescriptionTextForm(
                      descriptionController: _descriptionController,
                    ),

                    const SizedBox(height: 20),

                    // VALOR
                    const Text(
                      'Valor',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TransactionValueTextForm(valueController: _valueController),

                    const SizedBox(height: 20),

                    // CATEGORIA
                    const Text(
                      'Categoria',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TransactionCategoryDropdown(
                      selectedCategory: _category,
                      categoryType: _type,
                      onCategoryChanged: (category) {
                        setState(() {
                          _category = category;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // BOTÃO
                    TransactionSaveSizedbox(
                      saveTransaction: _saveChanges,
                      textButton: 'Salvar alterações'
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_category == null || _category!.type != _type) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria válida.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final value = double.parse(
        _valueController.text.replaceAll('.', '').replaceAll(',', '.'),
      );

      if (value <= 0) {
        throw const FormatException('O valor deve ser maior que zero.');
      }

      await _transactionRepository.update(
        id: _transaction.id,
        description: _descriptionController.text.trim(),
        categoryId: _category!.id,
        date: _transaction.date,
        value: value,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transação atualizada com sucesso!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Erro ao atualizar transação: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar transação.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
