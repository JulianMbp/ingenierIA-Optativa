import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_service.dart';
import 'connectivity_service.dart';

final bitacoraAiServiceProvider = Provider<BitacoraAiService>((ref) {
  return BitacoraAiService(
    ref.read(apiServiceProvider),
    ref.read(connectivityServiceProvider),
  );
});

class BitacoraAiService {
  final ApiService _apiService;
  final ConnectivityService _connectivityService;

  BitacoraAiService(
    this._apiService,
    this._connectivityService,
  );

  /// Genera un informe de bitácora usando IA
  Future<InformeBitacoraResponse> generarInforme({
    required String obraId,
    required List<String> actividades,
    required int avanceGeneral,
    String? fecha,
    String? clima,
    List<String>? incidencias,
    String? observaciones,
  }) async {
    final hasConnection = await _connectivityService.hasInternetConnection();

    if (!hasConnection) {
      throw Exception(
        'Sin conexión a internet. Por favor, verifica tu conexión e intenta nuevamente.',
      );
    }

    try {
      final body = {
        'actividades': actividades,
        'avanceGeneral': avanceGeneral,
        if (fecha != null) 'fecha': fecha,
        if (clima != null) 'clima': clima,
        if (incidencias != null && incidencias.isNotEmpty)
          'incidencias': incidencias,
        if (observaciones != null) 'observaciones': observaciones,
      };

      final response = await _apiService.post(
        '/obras/$obraId/bitacoras/generar-informe-ia',
        data: body,
      );

      final responseData = response.data;
      
      // La respuesta puede venir en dos formatos:
      // 1. {success: true, data: {html: "...", tokensUsados: ...}, message: "..."}
      // 2. {success: true, data: {success: true, data: {html: "...", tokensUsados: ...}, message: "..."}, message: "..."}
      
      // Si hay estructura anidada (data.data), usar la interna
      if (responseData is Map<String, dynamic> && 
          responseData['data'] is Map<String, dynamic> &&
          responseData['data']['data'] is Map<String, dynamic>) {
        // Estructura anidada: usar data.data
        final nestedData = responseData['data'] as Map<String, dynamic>;
        return InformeBitacoraResponse.fromJson(nestedData);
      }
      
      // Estructura directa
      return InformeBitacoraResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene todos los borradores pendientes de una obra
  /// Nota: Ya no se guardan borradores sin SQLite
  Future<List<InformeBorrador>> getBorradoresPendientes(
      String obraId) async {
    // Sin SQLite, no hay borradores guardados
    return [];
  }

  /// Genera informe desde un borrador guardado
  /// Nota: Ya no se guardan borradores sin SQLite
  Future<InformeBitacoraResponse> generarDesdeBorrador(
      InformeBorrador borrador) async {
    return await generarInforme(
      obraId: borrador.obraId,
      actividades: borrador.actividades,
      avanceGeneral: borrador.avanceGeneral,
      fecha: borrador.fecha,
      clima: borrador.clima,
      incidencias: borrador.incidencias,
      observaciones: borrador.observaciones,
    );
  }

  /// Marca un borrador como sincronizado
  /// Nota: Ya no se guardan borradores sin SQLite
  Future<void> marcarBorradorSincronizado(String borradorId) async {
    // Sin SQLite, no hay nada que hacer
  }

  /// Elimina un borrador
  /// Nota: Ya no se guardan borradores sin SQLite
  Future<void> eliminarBorrador(String borradorId) async {
    // Sin SQLite, no hay nada que hacer
  }

  /// Hace una pregunta a la IA sobre la obra
  Future<ChatResponse> hacerPregunta({
    required String obraId,
    required String mensaje,
  }) async {
    final hasConnection = await _connectivityService.hasInternetConnection();

    if (!hasConnection) {
      throw Exception(
        'Sin conexión a internet. Por favor, verifica tu conexión e intenta nuevamente.',
      );
    }

    try {
      final body = {
        'mensaje': mensaje,
      };

      final response = await _apiService.post(
        '/obras/$obraId/bitacoras/chat',
        data: body,
      );

      final responseData = response.data;
      
      // La respuesta puede venir en dos formatos:
      // 1. {success: true, data: {respuesta: "...", tokensUsados: ...}, message: "..."}
      // 2. {success: true, data: {success: true, data: {respuesta: "...", tokensUsados: ...}, message: "..."}, message: "..."}
      
      // Si hay estructura anidada (data.data), usar la interna
      if (responseData is Map<String, dynamic> && 
          responseData['data'] is Map<String, dynamic> &&
          responseData['data']['data'] is Map<String, dynamic>) {
        // Estructura anidada: usar data.data
        final nestedData = responseData['data'] as Map<String, dynamic>;
        return ChatResponse.fromJson(nestedData);
      }
      
      // Estructura directa
      return ChatResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }
}

/// Modelo de respuesta del informe generado
class InformeBitacoraResponse {
  final bool success;
  final InformeData data;
  final String message;

  InformeBitacoraResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory InformeBitacoraResponse.fromJson(Map<String, dynamic> json) {
    // Manejar estructura anidada: si data tiene un campo 'data' dentro, usar ese
    dynamic dataField = json['data'];
    if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
      // Estructura anidada: data.data contiene el InformeData
      dataField = dataField['data'];
    }
    
    return InformeBitacoraResponse(
      success: json['success'] ?? false,
      data: InformeData.fromJson(dataField ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class InformeData {
  final String html;
  final int? tokensUsados;

  InformeData({
    required this.html,
    this.tokensUsados,
  });

  factory InformeData.fromJson(Map<String, dynamic> json) {
    return InformeData(
      html: json['html'] ?? '',
      tokensUsados: json['tokensUsados'],
    );
  }
}

/// Modelo para borrador de informe
/// Nota: Ya no se usa sin SQLite, pero se mantiene por compatibilidad
class InformeBorrador {
  final String id;
  final String obraId;
  final List<String> actividades;
  final int avanceGeneral;
  final String? fecha;
  final String? clima;
  final List<String>? incidencias;
  final String? observaciones;
  final DateTime createdAt;
  final bool sincronizado;

  InformeBorrador({
    required this.id,
    required this.obraId,
    required this.actividades,
    required this.avanceGeneral,
    this.fecha,
    this.clima,
    this.incidencias,
    this.observaciones,
    required this.createdAt,
    required this.sincronizado,
  });
}

/// Modelo de respuesta del chat con IA
class ChatResponse {
  final bool success;
  final ChatData data;
  final String message;

  ChatResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    // Manejar estructura anidada: si data tiene un campo 'data' dentro, usar ese
    dynamic dataField = json['data'];
    if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
      // Estructura anidada: data.data contiene el ChatData
      dataField = dataField['data'];
    }
    
    return ChatResponse(
      success: json['success'] ?? false,
      data: ChatData.fromJson(dataField ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ChatData {
  final String respuesta;
  final int? tokensUsados;

  ChatData({
    required this.respuesta,
    this.tokensUsados,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      respuesta: json['respuesta'] ?? '',
      tokensUsados: json['tokensUsados'],
    );
  }
}
