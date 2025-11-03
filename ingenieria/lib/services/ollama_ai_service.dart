import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../core/utils/logger.dart';

/// Service for Ollama AI integration.
class OllamaAiService {
  late final Dio _dio;

  OllamaAiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.ollamaBaseUrl,
        connectTimeout: const Duration(seconds: 60), // AI requests may take longer
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_LoggingInterceptor());
  }

  /// Generate a text response using Ollama
  /// 
  /// [prompt] - The input text to process
  /// [model] - The model to use (default: 'llama2')
  /// [stream] - Whether to stream the response (default: false)
  Future<String> generateText({
    required String prompt,
    String model = 'llama2',
    bool stream = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.ollamaGenerateEndpoint,
        data: {
          'model': model,
          'prompt': prompt,
          'stream': stream,
        },
      );

      if (response.statusCode == 200) {
        return response.data['response'] as String? ?? '';
      } else {
        throw Exception('Failed to generate text: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Ollama generation failed', e, stackTrace);
      rethrow;
    }
  }

  /// Generate a progress report from work logs
  Future<String> generateProgressReport(String logsText) async {
    final prompt = '''
Based on the following work logs, generate a concise progress report in Spanish 
for a construction project. Include:
1. Summary of work completed
2. Key milestones achieved
3. Issues or delays if any
4. Next steps

Work Logs:
$logsText

Please provide a professional report:
''';

    return await generateText(prompt: prompt);
  }

  /// Summarize safety incidents
  Future<String> summarizeSafetyIncidents(String incidentsText) async {
    final prompt = '''
Based on the following safety incidents, provide a summary in Spanish that includes:
1. Total number of incidents
2. Types of incidents
3. Severity assessment
4. Recommended actions

Safety Incidents:
$incidentsText

Please provide a safety summary:
''';

    return await generateText(prompt: prompt);
  }

  /// Generate material usage analysis
  Future<String> analyzeMaterialUsage(String materialsData) async {
    final prompt = '''
Based on the following materials data, provide an analysis in Spanish that includes:
1. Most consumed materials
2. Usage trends
3. Cost analysis if available
4. Recommendations for optimization

Materials Data:
$materialsData

Please provide a material usage analysis:
''';

    return await generateText(prompt: prompt);
  }

  /// Generate embeddings for text
  Future<List<double>> generateEmbeddings({
    required String text,
    String model = 'llama2',
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.ollamaEmbeddingsEndpoint,
        data: {
          'model': model,
          'prompt': text,
        },
      );

      if (response.statusCode == 200) {
        final embeddings = response.data['embedding'] as List<dynamic>;
        return embeddings.map((e) => e as double).toList();
      } else {
        throw Exception('Failed to generate embeddings: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Embeddings generation failed', e, stackTrace);
      rethrow;
    }
  }

  /// Generate a custom report based on custom prompt
  Future<String> generateCustomReport({
    required String title,
    required String data,
    List<String>? sections,
  }) async {
    final sectionsText = sections?.join('\n') ?? 
        '1. Executive Summary\n2. Details\n3. Recommendations';
    
    final prompt = '''
Generate a professional report in Spanish with the following:

Title: $title

Required Sections:
$sectionsText

Data:
$data

Please provide a well-structured report:
''';

    return await generateText(prompt: prompt);
  }

  /// Check if Ollama service is available
  Future<bool> checkServiceAvailability() async {
    try {
      final response = await _dio.get('/api/tags');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.warning('Ollama service not available', e);
      return false;
    }
  }

  /// Get available models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await _dio.get('/api/tags');
      
      if (response.statusCode == 200) {
        final models = response.data['models'] as List<dynamic>;
        return models.map((m) => m['name'] as String).toList();
      } else {
        return ['llama2']; // Default model
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch available models', e);
      return ['llama2']; // Default model
    }
  }
}

/// Logging interceptor for Ollama requests
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('OLLAMA REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      'OLLAMA RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'OLLAMA ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      err.message,
    );
    handler.next(err);
  }
}
