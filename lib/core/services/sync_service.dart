import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';
import 'offline_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.read(offlineServiceProvider),
    ref.read(connectivityServiceProvider),
  );
});

/// Servicio para sincronización automática cuando se detecta conexión
class SyncService {
  final OfflineService _offlineService;
  final ConnectivityService _connectivityService;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _syncTimer;
  bool _isRunning = false;

  SyncService(this._offlineService, this._connectivityService);

  /// Iniciar el servicio de sincronización automática
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // Escuchar cambios en la conectividad
    _subscription = _connectivityService.connectivityStream.listen(
      (results) async {
        final hasConnection = !results.contains(ConnectivityResult.none);
        if (hasConnection) {
          // Cuando hay conexión, sincronizar inmediatamente
          await syncPendingRequests();
        }
      },
    );

    // Sincronizar periódicamente cada 30 segundos si hay conexión
    _syncTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        final hasConnection = await _offlineService.hasConnection();
        if (hasConnection) {
          await syncPendingRequests();
        }
      },
    );

    // Sincronizar inmediatamente si hay conexión al iniciar
    _offlineService.hasConnection().then((hasConnection) {
      if (hasConnection) {
        syncPendingRequests();
      }
    });
  }

  /// Detener el servicio de sincronización
  void stop() {
    _isRunning = false;
    _subscription?.cancel();
    _syncTimer?.cancel();
  }

  /// Sincronizar peticiones pendientes
  Future<void> syncPendingRequests() async {
    try {
      await _offlineService.syncPendingRequests();
    } catch (e) {
      print('Error al sincronizar: $e');
    }
  }

  /// Forzar sincronización manual
  Future<void> forceSync() async {
    await syncPendingRequests();
  }
}

