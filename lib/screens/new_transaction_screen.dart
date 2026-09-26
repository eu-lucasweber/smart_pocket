import 'package:flutter/material.dart';
import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/widgets/transactions/transaction_category_dropdown.dart';
import 'package:smart_pocket/widgets/transactions/transaction_description_textform.dart';
import 'package:smart_pocket/widgets/transactions/transaction_save_sizedbox.dart';
import 'package:smart_pocket/widgets/transactions/transaction_value_textform.dart';
import '../widgets/transactions/transaction_type_selector.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  CategoryType _type = CategoryType.expense;
  Category? _category;

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
                'Valor',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TransactionValueTextForm(
                valueController: _valueController
              ),

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

              TransactionSaveSizedbox(saveTransaction: _saveTransaction, textButton: 'Salvar transação'),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transação cadastrada com sucesso!')),
    );

    Navigator.pop(context);
  }
}
