import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/models/categoryTotal.dart';
import 'package:smart_pocket/models/transaction.dart';

class CategoryChart extends StatelessWidget {
  final List<Transaction> transactions;

  const CategoryChart({super.key, required this.transactions});

  final _baseColors = const [
    Color(0xFF008F63),
    Color(0xFF4C9952),
    Color(0xFF91C788),
  ];

  /// Retorna [count] cores, da mais escura à mais clara.
  List<Color> generateColors(int count) {
    if (count <= 0) return [];
    if (count == 1) return [_baseColors.first];

    return List.generate(count, (i) {
      final t = i / (count - 1); // 0.0 → 1.0
      final scaled =
          t * (_baseColors.length - 1); // posição entre as cores base
      final index = scaled.floor().clamp(0, _baseColors.length - 2);
      final localT = scaled - index;

      return Color.lerp(_baseColors[index], _baseColors[index + 1], localT)!;
    });
  }

  List<CategoryTotal> groupByCategory(List<Transaction> transactions) {
    final Map<int, CategoryTotal> grouped = {};

    for (final item in transactions) {
      final id = item.category.id;
      final current = grouped[id];

      grouped[id] = CategoryTotal(
        categoryId: id,
        categoryName: item.category.name,
        total: (current?.total ?? 0) + item.value,
      );
    }

    return grouped.values.toList()..sort((a, b) => b.total.compareTo(a.total));
  }

  @override
  Widget build(BuildContext context) {
    final expenseTransactions = transactions
        .where((item) => item.category.type == CategoryType.expense)
        .toList();

    final categoryTotals = groupByCategory(expenseTransactions);
    final colors = generateColors(categoryTotals.length);
    final grandTotal = categoryTotals.fold<double>(
      0,
      (sum, c) => sum + c.total,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Despesas por categoria',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 190,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomPaint(
                    size: const Size(150, 150),
                    painter: DonutChartPainter(
                      values: categoryTotals.map((c) => c.total).toList(),
                      colors: colors,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < categoryTotals.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _LegendItem(
                          color: colors[i],
                          label: categoryTotals[i].categoryName,
                          percentage: grandTotal == 0
                              ? '0%'
                              : '${(categoryTotals[i].total / grandTotal * 100).round()}%',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 7),

        Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),

        Text(
          percentage,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  const DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    final total = values.fold<double>(0, (sum, v) => sum + v);
    if (total == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = 2 * pi * (values[i] / total);

      paint.color = colors[i];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }

    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 15, centerPaint);
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
