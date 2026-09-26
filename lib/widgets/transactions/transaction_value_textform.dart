import 'package:flutter/material.dart';

class TransactionValueTextForm extends StatelessWidget {
  final TextEditingController valueController;

  const TransactionValueTextForm({
    super.key,
    required this.valueController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: valueController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        prefixText: 'R\$ ',
        hintText: '0,00',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe o valor';
        }

        final number = double.tryParse(value.replaceAll(',', '.'));

        if (number == null || number <= 0) {
          return 'Informe um valor válido';
        }

        return null;
      },
    );
  }
}
