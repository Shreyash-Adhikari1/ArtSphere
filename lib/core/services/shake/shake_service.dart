import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shake_plus/shake_plus.dart';

class ShakeService {
  ShakeService({
    int shakeSlopTimeMS = 500,
    double shakeThresholdGravity = 2.7,
  }) {
    _controller = StreamController<void>.broadcast();

    _detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        debugPrint("📳 SHAKE DETECTED");
        if (_controller.isClosed) return;
        _controller.add(null);
      },
      shakeSlopTimeMS: shakeSlopTimeMS,
      shakeThresholdGravity: shakeThresholdGravity,
    );
  }

  late final ShakeDetector _detector;
  late final StreamController<void> _controller;

  Stream<void> get shakes => _controller.stream;

  void dispose() {
    _detector.stopListening();
    _controller.close();
  }
}
