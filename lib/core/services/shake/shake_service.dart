import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shake_plus/shake_plus.dart';

class ShakeService {
  ShakeService({
    int shakeSlopTimeMS = 500,
    double shakeThresholdGravity = 2.7,
  }) {
    _controller = StreamController<int>.broadcast();

    _detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        debugPrint("📳 SHAKE DETECTED");
        if (_controller.isClosed) return;
        _seq++;
        _controller.add(_seq); // ✅ unique value every shake
      },
      shakeSlopTimeMS: shakeSlopTimeMS,
      shakeThresholdGravity: shakeThresholdGravity,
    );
  }

  late final ShakeDetector _detector;
  late final StreamController<int> _controller;

  int _seq = 0;

  Stream<int> get shakes => _controller.stream;

  void dispose() {
    _detector.stopListening();
    _controller.close();
  }
}
