import 'package:flutter/material.dart';
import 'shapes.dart';

class BubbleDecoration {
  final Color backgroundColor;
  final Color selectedBubbleBackgroundColor;
  final Color unSelectedBubbleBackgroundColor;
  final Color selectedBubbleLabelColor;
  final Color unSelectedBubbleLabelColor;
  final Color selectedBubbleIconColor;
  final Color unSelectedBubbleIconColor;
  final TextStyle selectedBubbleLabelStyle;
  final TextStyle unSelectedBubbleLabelStyle;
  final double iconSize;
  final double innerIconLabelSpacing;
  final ScrollPhysics physics;
  final Duration bubbleDuration;
  final Duration? screenTransitionDuration;
  final AnimatedSwitcherTransitionBuilder? screenTransitionBuilder;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Curve curveIn;
  final Curve curveOut;
  final Axis axis;
  final double bubbleItemSize;
  final Alignment alignment;
  final BubbleShape shapes;
  final double? squareBordersRadius;

  const BubbleDecoration({
    this.selectedBubbleBackgroundColor = Colors.white70,
    this.unSelectedBubbleBackgroundColor = Colors.deepPurple,
    this.selectedBubbleLabelColor = Colors.black87,
    this.unSelectedBubbleLabelColor = Colors.white70,
    this.selectedBubbleIconColor = Colors.black87,
    this.unSelectedBubbleIconColor = Colors.white70,
    this.selectedBubbleLabelStyle = const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal),
    this.unSelectedBubbleLabelStyle = const TextStyle(
        fontSize: 13, fontWeight: FontWeight.bold, fontStyle: FontStyle.normal),
    this.iconSize = 30,
    this.backgroundColor = Colors.deepPurpleAccent,
    this.innerIconLabelSpacing = 5,
    this.bubbleItemSize = 10,
    this.physics = const BouncingScrollPhysics(),
    this.bubbleDuration = const Duration(milliseconds: 300),
    this.screenTransitionDuration,
    this.screenTransitionBuilder,
    this.margin = const EdgeInsets.all(5),
    this.padding = const EdgeInsets.all(5),
    this.curveIn = Curves.easeIn,
    this.curveOut = Curves.easeOut,
    this.axis = Axis.horizontal,
    this.alignment = Alignment.bottomCenter,
    this.shapes = BubbleShape.circular,
    this.squareBordersRadius,
  });
}
