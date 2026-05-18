import 'package:flutter/cupertino.dart';

class PillChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final double fontSize;

  const PillChip({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
