import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Servicio para detectar el estado de conexión a internet
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  /// Stream de cambios en la conectividad
  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Verificar si hay conexión a internet actualmente
  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      // Verificar que no esté en none
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Obtener el estado actual de conectividad
  Future<List<ConnectivityResult>> getConnectivityStatus() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return [ConnectivityResult.none];
    }
  }

  /// Verificar si hay conexión WiFi
  Future<bool> isConnectedViaWifi() async {
    final result = await getConnectivityStatus();
    return result.contains(ConnectivityResult.wifi);
  }

  /// Verificar si hay conexión móvil
  Future<bool> isConnectedViaMobile() async {
    final result = await getConnectivityStatus();
    return result.contains(ConnectivityResult.mobile);
  }

  /// Disposer para limpiar recursos
  void dispose() {
    _subscription?.cancel();
  }
}

/// Provider para el estado de conectividad en tiempo real
final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectivityStream;
});

/// Provider para verificar si hay internet
final hasInternetProvider = FutureProvider<bool>((ref) async {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return await connectivityService.hasInternetConnection();
});

