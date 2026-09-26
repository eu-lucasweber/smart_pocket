import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final String value;

  const BalanceCard({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF008F63),
            Color(0xFF4C9952),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}