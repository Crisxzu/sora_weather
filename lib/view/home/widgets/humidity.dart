import 'package:flutter/material.dart';

import '../../../common/utils.dart';

class HumidityView extends StatelessWidget {
  final int humidity; // Percentage value (0-100)
  final Color dropColor;

  const HumidityView({
    super.key,
    required this.humidity,
    this.dropColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Water drop shape
          Center(
            child: CustomPaint(
              size: const Size(20, 20),
              painter: DropPainter(
                fillPercentage: humidity / 100,
                dropColor: dropColor,
              ),
            ),
          ),
          Text(
              "$humidity%",
            style: Utils.mobileTextStyle['body'],
          )
        ],
      ),
    );
  }
}

class DropPainter extends CustomPainter {
  final double fillPercentage; // Value between 0.0 and 1.0
  final Color dropColor;

  DropPainter({
    required this.fillPercentage,
    required this.dropColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the water drop outline
    final dropPath = Path();
    dropPath.moveTo(size.width / 2, 0);
    dropPath.cubicTo(
        size.width * 0.8, size.height * 0.3,
        size.width, size.height * 0.9,
        size.width / 2, size.height
    );
    dropPath.cubicTo(
        0, size.height * 1,
        size.width * 0.2, size.height * 0.3,
        size.width / 2, 0.6
    );

    // Draw the drop outline
    final outlinePaint = Paint()
      ..color = dropColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(dropPath, outlinePaint);

    // Create a clipping path for the fill
    // Calculate fill height based on percentage (inverted, as we fill from bottom to top)
    final fillHeight = size.height * fillPercentage;
    final fillY = size.height - fillHeight;

    // Create a rectangle path for the fill area
    final fillRect = Rect.fromLTWH(0, fillY, size.width, fillHeight);

    // Clip the fill to the drop shape
    canvas.clipPath(dropPath);

    // Draw the fill
    final fillPaint = Paint()
      ..color = dropColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(fillRect, fillPaint);
  }

  @override
  bool shouldRepaint(DropPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage ||
        oldDelegate.dropColor != dropColor;
  }
}