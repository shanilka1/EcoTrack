import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility to debounce fast repetitive events (such as user text input)
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Runs the action after the specified delay has passed without further calls
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any scheduled action
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer
  void dispose() {
    _timer?.cancel();
  }
}
