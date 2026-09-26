import 'package:flutter/material.dart';
import 'package:smart_pocket/models/transaction.dart';
import 'package:smart_pocket/widgets/transactions/transaction_category_dropdown.dart';
import 'package:smart_pocket/widgets/transactions/transaction_description_textform.dart';
import 'package:smart_pocket/widgets/transactions/transaction_save_sizedbox.dart';
import 'package:smart_pocket/widgets/transactions/transaction_value_textform.dart';
import '../widgets/transactions/transaction_type_selector.dart';

//type
import '../models/category.dart';
//mock
import '../mocks/category_mock.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isInit = true;

  late TextEditingController _descriptionController;
  late TextEditingController _valueController;

  CategoryType _type = CategoryType.income;
  Category? _category;

  @override
  void initState() {
    super.initState();

    _descriptionController = TextEditingController();
    _valueController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      final transaction =
          ModalRoute.of(context)!.settings.arguments as Transaction;

      _descriptionController.text = transaction.description;
      _valueController.text = transaction.value.toStringAsFixed(2);
      _type = transaction.type;

      _category = CategoryMock.categories.firstWhere(
        (cat) => cat.id == transaction.category.id,
        orElse: () => transaction.category,
      );

      _isInit = false;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryObject = CategoryMock.categories.firstWhere(
      (cat) => cat.name == _category?.name && cat.type == _type,
    );

    final updatedTransaction = {
      'description': _descriptionController.text.trim(),
      'category': categoryObject,
      'date': transaction.date,
      'value': double.parse(_valueController.text.replaceAll(',', '.')),
      'type': _type,
    };

    Navigator.pop(context, updatedTransaction);
  }

  late Transaction transaction;

  @override
  Widget build(BuildContext context) {
    transaction = ModalRoute.of(context)!.settings.arguments as Transaction;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text('Editar transação'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar lançamento',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Altere as informações da sua transação.',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 24),

              // TIPO
              const Text('Tipo', style: TextStyle(fontWeight: FontWeight.w600)),

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
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TransactionDescriptionTextForm(
                descriptionController: _descriptionController,
              ),

              const SizedBox(height: 20),

              // VALOR
              const Text(
                'Valor',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TransactionValueTextForm(
                valueController: _valueController
              ),

              const SizedBox(height: 20),

              // CATEGORIA
              const Text(
                'Categoria',
                style: TextStyle(fontWeight: FontWeight.w600),
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
              TransactionSaveSizedbox(saveTransaction: _saveChanges, textButton: 'Salvar alterações'),
            ],
          ),
        ),
      ),
    );
  }
}
