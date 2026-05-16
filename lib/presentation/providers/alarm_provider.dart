import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/platform/alarm_bridge.dart';

final alarmProvider = Provider((ref) => AlarmBridge());
