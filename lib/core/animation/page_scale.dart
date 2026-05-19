import 'package:flutter/material.dart';

final pageScaleNotifier = ValueNotifier<double>(1.0);

class PageScaleProvider extends InheritedNotifier<ValueNotifier<double>> {
  const PageScaleProvider({
    super.key,
    required ValueNotifier<double> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ValueNotifier<double> of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PageScaleProvider>()!.notifier!;
  }
}
