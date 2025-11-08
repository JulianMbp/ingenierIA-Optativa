import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';

final offlineServiceProvider = Provider<OfflineService>((ref) {
  return OfflineService(
    ref.read(connectivityServiceProvider),
  );
});

/// Servicio para manejar operaciones offline
/// Simplificado: solo verifica conectividad
class OfflineService {
  final ConnectivityService _connectivityService;

  OfflineService(
    this._connectivityService,
  );

  /// Verificar si hay conexión a internet
  Future<bool> hasConnection() async {
    return await _connectivityService.hasInternetConnection();
  }

  /// Sincronizar peticiones pendientes
  /// Nota: Ya no hay cola de peticiones pendientes sin SQLite
  Future<void> syncPendingRequests() async {
    // No hay nada que sincronizar sin SQLite
    // Las peticiones se hacen directamente cuando hay conexión
  }
}
