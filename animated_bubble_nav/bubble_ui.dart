import 'package:flutter/material.dart';
import 'providers.dart';
import 'bubble_model.dart';
import 'decoration.dart';
import 'combined_widgets.dart';

class CustomBubbleNavBar extends StatefulWidget {
  final List<BubbleItem> items;
  final BubbleDecoration bubbleDecoration;

  const CustomBubbleNavBar({
    super.key,
    required this.items,
    required this.bubbleDecoration,
  });

  @override
  State<CustomBubbleNavBar> createState() => CustomBubbleNavBarState();
}

class CustomBubbleNavBarState extends State<CustomBubbleNavBar> {
  @override
  Widget build(BuildContext context) {
    final bubble = widget.bubbleDecoration;
    final isHorizontal = bubble.axis == Axis.horizontal;

    return Align(
      alignment: bubble.alignment,
      child: Container(
        margin: bubble.margin,
        padding: bubble.padding,
        decoration: BoxDecoration(
          color: widget.bubbleDecoration.backgroundColor,
          borderRadius: BorderRadius.circular(bubble.shapes.shape),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(bubble.shapes.shape),
          child: SingleChildScrollView(
            scrollDirection: bubble.axis,
            physics: bubble.physics,
            child: isHorizontal
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildItems(bubble, isHorizontal),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildItems(bubble, isHorizontal),
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(BubbleDecoration bubble, bool isHorizontal) {
    return List.generate(widget.items.length, (index) {
      return GestureDetector(
        onTap: () {
          if (selectedIndexNotifier.value != index) {
            selectedIndexNotifier.value = index;
          }
        },
        child: ValueListenableBuilder<int>(
          valueListenable: selectedIndexNotifier,
          builder: (context, selectedIndex, _) {
            final isSelected = index == selectedIndex;
            return AnimatedContainer(
              duration: bubble.bubbleDuration,
              curve: bubble.curveIn,
              padding: EdgeInsets.all(bubble.bubbleItemSize),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.bubbleDecoration.selectedBubbleBackgroundColor
                    : widget.bubbleDecoration.unSelectedBubbleBackgroundColor,
                borderRadius: BorderRadius.circular(
                    bubble.squareBordersRadius ?? bubble.shapes.shape),
              ),
              child: isHorizontal
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          _buildLabelIcons(index, isSelected, isHorizontal),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          _buildLabelIcons(index, isSelected, isHorizontal)),
            );
          },
        ),
      );
    });
  }

  List<Widget> _buildLabelIcons(
      int index, bool isSelected, bool isHorizontal) {
    final bubble = widget.bubbleDecoration;
    final item = widget.items[index];
    return [
      BubbleWidgets.buildIcon(bubble, item, isSelected, isHorizontal),
      if (isSelected)
        SizedBox(
          width: isHorizontal ? bubble.innerIconLabelSpacing : 0,
          height: isHorizontal ? 0 : bubble.innerIconLabelSpacing,
        ),
      AnimatedSize(
        duration: bubble.bubbleDuration,
        curve: bubble.curveIn,
        child: isSelected
            ? BubbleWidgets.buildLabel(
                bubble, item.label, isSelected, isHorizontal)
            : const SizedBox.shrink(),
      ),
    ];
  }
}
