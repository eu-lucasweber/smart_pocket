
import 'package:flutter/material.dart';

class AppSettingsCard extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencyChanged;

  final VoidCallback onClearTransactions;
  final VoidCallback onLogout;

  const AppSettingsCard({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.onClearTransactions,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações do app',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Moeda',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'BRL',
                  label: Text('BRL'),
                ),
                ButtonSegment<String>(
                  value: 'USD',
                  label: Text('USD'),
                ),
                ButtonSegment<String>(
                  value: 'EUR',
                  label: Text('EUR'),
                ),
              ],
              selected: {selectedCurrency},
              onSelectionChanged: (selection) {
                onCurrencyChanged(selection.first);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: const Color(0xFF28C76F),
                selectedForegroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onClearTransactions,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Limpar transações'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade800,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
