import 'package:flutter/material.dart';
import 'bubble_model.dart';
import 'decoration.dart';

class BubbleWidgets {
  static Widget buildIcon(BubbleDecoration bubble, BubbleItem item,
      bool isSelected, bool isHorizontal) {
    if (item.icon != null) {
      return Icon(
        item.icon,
        color: isSelected
            ? bubble.selectedBubbleIconColor
            : bubble.unSelectedBubbleIconColor,
        size: bubble.iconSize,
      );
    } else if (item.iconWidget != null) {
      return item.iconWidget!;
    } else if (!isSelected) {
      return buildLabel(
          bubble, " ${item.label[0].toUpperCase()}", isSelected, isHorizontal);
    }
    return const SizedBox.shrink();
  }

  static Widget buildLabel(BubbleDecoration bubble, String label,
      bool isSelected, bool isHorizontal) {
    final displayLabel = isHorizontal ? label : label.split('').join('\n');

    return Text(displayLabel,
        textAlign: TextAlign.center,
        style: isSelected
            ? bubble.selectedBubbleLabelStyle
            : bubble.unSelectedBubbleLabelStyle);
  }
}
