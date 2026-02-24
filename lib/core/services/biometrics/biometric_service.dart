import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(LocalAuthentication());
});

class BiometricService {
  final LocalAuthentication _auth;
  BiometricService(this._auth);

  Future<bool> canCheck() async {
    final canCheck = await _auth.canCheckBiometrics;
    final supported = await _auth.isDeviceSupported();
    return canCheck && supported;
  }

  Future<bool> authenticate() async {
    debugPrint("BIO: authenticate() called");
    try {
      final ok = await _auth.authenticate(
        localizedReason: "Unlock Artsphere with fingerprint",
        biometricOnly: true,
        // replacement for the old "stickyAuth" behavior:
        persistAcrossBackgrounding: true,
      );
      debugPrint("BIO: authenticate() result=$ok");
      return ok;
    } on LocalAuthException catch (e) {
      debugPrint("BIO: LocalAuthException code=${e.code}");
      return false;
    } catch (e) {
      debugPrint("BIO: unknown error: $e");
      return false;
    }
  }
}
