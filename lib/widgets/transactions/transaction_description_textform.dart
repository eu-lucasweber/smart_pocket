import 'package:flutter/material.dart';

class TransactionDescriptionTextForm extends StatelessWidget {
  final TextEditingController descriptionController;

  const TransactionDescriptionTextForm({
    super.key,
    required this.descriptionController
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: descriptionController,
      decoration: const InputDecoration(
        hintText: 'Ex.: Supermercado',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe a descrição';
        }

        return null;
      },
    );
  }
}
