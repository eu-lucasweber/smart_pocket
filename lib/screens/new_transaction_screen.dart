import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/repositories/transaction_repository.dart';

import 'package:smart_pocket/widgets/transactions/transaction_category_dropdown.dart';
import 'package:smart_pocket/widgets/transactions/transaction_date_picker.dart';
import 'package:smart_pocket/widgets/transactions/transaction_description_textform.dart';
import 'package:smart_pocket/widgets/transactions/transaction_save_sizedbox.dart';
import 'package:smart_pocket/widgets/transactions/transaction_value_textform.dart';
import 'package:smart_pocket/widgets/transactions/transaction_type_selector.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final TransactionRepository _transactionRepository = TransactionRepository();

  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  CategoryType _type = CategoryType.expense;
  Category? _category;

  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Nova transação',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

              const Text(
                'Descrição',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TransactionDescriptionTextForm(
                descriptionController: _descriptionController,
              ),

              const SizedBox(height: 20),

              const Text(
                'Data',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TransactionDatePicker(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Valor',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TransactionValueTextForm(valueController: _valueController),

              const SizedBox(height: 20),

              const Text(
                'Categoria',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

              const SizedBox(height: 30),

              TransactionSaveSizedbox(
                saveTransaction: _saveTransaction,
                textButton: _isSaving ? 'Salvando...' : 'Salvar transação',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
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

      final date = DateFormat('dd/MM/yyyy').format(_selectedDate);

      await _transactionRepository.insert(
        description: _descriptionController.text.trim(),
        categoryId: _category!.id,
        date: date,
        value: value,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transação cadastrada com sucesso!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Erro ao salvar transação: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar transação.')),
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
