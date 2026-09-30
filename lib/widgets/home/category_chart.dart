import 'dart:math';

import 'package:flutter/material.dart';

class CategoryChart extends StatelessWidget {
  final String totalBalance;

  const CategoryChart(
    {
      super.key,
      required this.totalBalance
    }
  );

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            totalBalance,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 190,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomPaint(
                    painter: DonutChartPainter(),
                    child: const SizedBox.expand(),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _LegendItem(
                        color: Color(0xFF008F63),
                        label: 'Moradia',
                        percentage: '63%',
                      ),
                      SizedBox(height: 12),
                      _LegendItem(
                        color: Color(0xFF4C9952),
                        label: 'Alimentação',
                        percentage: '26%',
                      ),
                      SizedBox(height: 12),
                      _LegendItem(
                        color: Color(0xFF91C788),
                        label: 'Transporte',
                        percentage: '12%',
                      ),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ),

        Text(
          percentage,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = min(size.width, size.height) / 2 - 10;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.butt;

    final values = [63.0, 26.0, 12.0];

    final colors = [
      const Color(0xFF008F63),
      const Color(0xFF4C9952),
      const Color(0xFF91C788),
    ];

    double startAngle = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = 2 * pi * (values[i] / 101);

      paint.color = colors[i];

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
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

    canvas.drawCircle(
      center,
      radius - 15,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}