import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

/// Помилка з текстом, який можна показати користувачу.
class GeminiException implements Exception {
  const GeminiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Запити до Gemini API (generateContent і streamGenerateContent).
class GeminiService {
  GeminiService({
    required this.apiKey,
    this.model = 'gemini-3.5-flash-lite',
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  static const _base = 'https://generativelanguage.googleapis.com/v1beta/models';

  final String apiKey;
  final String model;
  final Duration timeout;
  final http.Client _client;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      };

  String _body(List<ChatMessage> history) => jsonEncode({
        'contents': history.where((m) => !m.isError).map((m) => m.toContent()).toList(),
      });

  /// Звичайний запит: відповідь приходить цілою.
  Future<String> generate(List<ChatMessage> history) async {
    final uri = Uri.parse('$_base/$model:generateContent');
    try {
      final response = await _client
          .post(uri, headers: _headers, body: _body(history))
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw _errorFor(response.statusCode, response.body);
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return _textFrom(data);
    } on SocketException {
      throw const GeminiException('Немає з\'єднання з інтернетом');
    } on TimeoutException {
      throw const GeminiException('Сервер не відповів за 30 секунд');
    } on http.ClientException catch (e) {
      throw GeminiException('Помилка мережі: ${e.message}');
    }
  }

  /// Стрімінг (alt=sse): текст приходить частинами по мірі генерації.
  Stream<String> generateStream(List<ChatMessage> history) async* {
    final uri = Uri.parse('$_base/$model:streamGenerateContent?alt=sse');
    final request = http.Request('POST', uri)
      ..headers.addAll(_headers)
      ..body = _body(history);

    http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(timeout);
    } on SocketException {
      throw const GeminiException('Немає з\'єднання з інтернетом');
    } on TimeoutException {
      throw const GeminiException('Сервер не відповів за 30 секунд');
    } on http.ClientException catch (e) {
      throw GeminiException('Помилка мережі: ${e.message}');
    }

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw _errorFor(response.statusCode, body);
    }

    // LineSplitter збирає рядок, навіть якщо він прийшов у двох шматках потоку.
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data: ')) continue;
      final payload = line.substring(6).trim();
      if (payload.isEmpty) continue;
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final text = _textFrom(data, allowEmpty: true);
      if (text.isNotEmpty) yield text;
    }
  }

  /// Дістаю текст з candidates[0].content.parts.
  String _textFrom(Map<String, dynamic> data, {bool allowEmpty = false}) {
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      if (allowEmpty) return '';
      final reason = (data['promptFeedback'] as Map?)?['blockReason'];
      throw GeminiException(
        reason != null
            ? 'Модель не відповіла: запит заблоковано ($reason)'
            : 'Модель повернула порожню відповідь',
      );
    }
    final parts = (candidates.first['content']?['parts'] as List?) ?? const [];
    return parts.map((p) => (p as Map)['text'] ?? '').join();
  }

  /// Перекладаю HTTP-код у зрозуміле повідомлення.
  GeminiException _errorFor(int code, String body) {
    String? apiMessage;
    try {
      apiMessage = (jsonDecode(body) as Map)['error']?['message'] as String?;
    } catch (_) {}
    final text = switch (code) {
      400 => 'Некоректний запит',
      401 || 403 => 'Проблема з API-ключем: перевірте GEMINI_API_KEY',
      404 => 'Модель $model не знайдена',
      429 => 'Перевищено ліміт безкоштовного тарифу, спробуйте за хвилину',
      >= 500 => 'Сервер Gemini тимчасово недоступний',
      _ => 'Помилка $code',
    };
    return GeminiException(
      apiMessage == null ? '$text ($code)' : '$text ($code): $apiMessage',
      statusCode: code,
    );
  }

  void close() => _client.close();
}
