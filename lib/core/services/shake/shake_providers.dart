import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'shake_service.dart';

final shakeServiceProvider = Provider<ShakeService>((ref) {
  final service = ShakeService();
  ref.onDispose(service.dispose);
  return service;
});

final shakeStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(shakeServiceProvider);
  return service.shakes;
});

class ActivePostFocus {
  final String? postId;
  final double fraction;

  const ActivePostFocus({required this.postId, required this.fraction});

  static const empty = ActivePostFocus(postId: null, fraction: 0);
}

final activePostFocusProvider = StateProvider<ActivePostFocus>(
  (ref) => ActivePostFocus.empty,
);
