import 'package:flutter/material.dart';

class TransactionSaveSizedbox extends StatelessWidget {
  final void Function() saveTransaction;
  final String textButton;

  const TransactionSaveSizedbox({
    super.key,
    required this.saveTransaction,
    required this.textButton
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A875),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(textButton),
      ),
    );
  }
}
