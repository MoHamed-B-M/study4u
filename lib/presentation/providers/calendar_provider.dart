import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/platform/calendar_bridge.dart';

final calendarSyncProvider = Provider((ref) => CalendarBridge());
