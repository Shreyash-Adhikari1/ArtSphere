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
    try {
      return await _auth.authenticate(
        localizedReason: "Unlock Artsphere with fingerprint",
        biometricOnly: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}
