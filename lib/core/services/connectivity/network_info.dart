import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

// Network Info Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(connectivity: Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;
  NetworkInfo({required Connectivity connectivity})
    : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    // check if Wi-Fi or Mobile Data is turned on
    final result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    // To check if internet is actually working or not 
    return await _isInternetConnectedTrue();
    // return true;
  }

  Future<bool> _isInternetConnectedTrue() async {
    try {
      final result = await InternetAddress.lookup("google.com");
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
