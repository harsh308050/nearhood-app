import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nearhood/core/network/network_utils.dart';

class ConnectivityService {
  ConnectivityService._privateConstructor() {
    _startMonitoring();
  }

  static final ConnectivityService instance = ConnectivityService._privateConstructor();

  final StreamController<bool> _connectivityStreamController = StreamController<bool>.broadcast();
  bool _isConnected = true;
  Timer? _timer;
  bool _isChecking = false;

  Stream<bool> get onConnectivityChanged => _connectivityStreamController.stream;
  bool get isConnected => _isConnected;

  void _startMonitoring() {
    // Check initial connectivity
    checkConnection();
    
    // Check periodically every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => checkConnection());
  }

  Future<void> checkConnection() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final bool currentStatus = await hasConnectivity();
      if (currentStatus != _isConnected) {
        _isConnected = currentStatus;
        _connectivityStreamController.add(_isConnected);
        debugPrint('📶 Connectivity Status Changed: $_isConnected');
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    } finally {
      _isChecking = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _connectivityStreamController.close();
  }
}
