import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_chat_app/models/chat_message.dart';
import 'package:gemini_chat_app/services/gemini_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _history = [ChatMessage(role: ChatRole.user, text: 'Привіт')];

String _answer(String text) => jsonEncode({
      'candidates': [
        {
          'content': {
            'role': 'model',
            'parts': [
              {'text': text},
            ],
          },
        },
      ],
    });

void main() {
  test('generate: розбирає candidates[0].content.parts[0].text', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(_answer('Вітаю!'), 200,
          headers: {'content-type': 'application/json; charset=utf-8'});
    });
    final service = GeminiService(apiKey: 'test-key', client: client);

    expect(await service.generate(_history), 'Вітаю!');
    expect(sent.url.path, endsWith(':generateContent'));
    expect(sent.headers['x-goog-api-key'], 'test-key');
    final body = jsonDecode(sent.body) as Map;
    expect(body['contents'][0]['role'], 'user');
    expect(body['contents'][0]['parts'][0]['text'], 'Привіт');
  });

  test('generate: порожній candidates дає зрозумілу помилку', () async {
    final client = MockClient((_) async => http.Response(
        jsonEncode({'promptFeedback': {'blockReason': 'SAFETY'}}), 200));
    final service = GeminiService(apiKey: 'k', client: client);

    expect(
      service.generate(_history),
      throwsA(isA<GeminiException>().having(
          (e) => e.message, 'message', contains('заблоковано (SAFETY)'))),
    );
  });

  for (final code in [400, 403, 429, 503]) {
    test('generate: код $code перетворюється в GeminiException', () async {
      final client = MockClient((_) async => http.Response(
          jsonEncode({'error': {'message': 'details'}}), code));
      final service = GeminiService(apiKey: 'k', client: client);

      await expectLater(
        service.generate(_history),
        throwsA(isA<GeminiException>()
            .having((e) => e.statusCode, 'statusCode', code)),
      );
    });
  }

  test('ключ-заглушка кирилицею не відправляється', () async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return http.Response('', 200);
    });
    final service = GeminiService(apiKey: 'ваш_ключ_тут', client: client);

    await expectLater(
      service.generate(_history),
      throwsA(isA<GeminiException>()
          .having((e) => e.message, 'message', contains('API-ключ не задано'))),
    );
    expect(calls, 0);
  });

  test('400 з API_KEY_INVALID показується як проблема з ключем', () async {
    final client = MockClient((_) async => http.Response(
        jsonEncode({
          'error': {
            'code': 400,
            'message': 'API key not valid. Please pass a valid API key.',
            'details': [
              {'reason': 'API_KEY_INVALID'},
            ],
          },
        }),
        400));
    final service = GeminiService(apiKey: 'wrong-key', client: client);

    await expectLater(
      service.generate(_history),
      throwsA(isA<GeminiException>()
          .having((e) => e.message, 'message', startsWith('Проблема з API-ключем'))),
    );
  });

  test('generateStream: збирає частини SSE, навіть розірвані між чанками', () async {
    final event1 = 'data: ${_answer('Пер')}\r\n\r\n';
    final event2 = 'data: ${_answer('ший ')}\r\n\r\n';
    final event3 = 'data: ${_answer('шматок')}\r\n\r\n';
    final all = utf8.encode(event1 + event2 + event3);
    // ріжу байти так, щоб JSON другої події прийшов у двох частинах
    final cut = utf8.encode(event1).length + 25;
    final client = MockClient.streaming((request, _) async {
      expect(request.url.query, 'alt=sse');
      return http.StreamedResponse(
        Stream.fromIterable([all.sublist(0, cut), all.sublist(cut)]),
        200,
      );
    });
    final service = GeminiService(apiKey: 'k', client: client);

    final parts = await service.generateStream(_history).toList();
    expect(parts, ['Пер', 'ший ', 'шматок']);
    expect(parts.join(), 'Перший шматок');
  });

  test('generateStream: помилка 503 посеред стріму не губиться', () async {
    final ok = 'data: ${_answer('Ось 5 пунктів')}\r\n\r\n';
    final err = 'data: ${jsonEncode({
          'error': {
            'code': 503,
            'message': 'high demand',
            'status': 'UNAVAILABLE',
          },
        })}\r\n\r\n';
    final client = MockClient.streaming((request, _) async =>
        http.StreamedResponse(Stream.value(utf8.encode(ok + err)), 200));
    final service = GeminiService(apiKey: 'k', client: client);

    final parts = <String>[];
    await expectLater(
      service.generateStream(_history).forEach(parts.add),
      throwsA(isA<GeminiException>()
          .having((e) => e.statusCode, 'statusCode', 503)
          .having((e) => e.message, 'message', contains('high demand'))),
    );
    // те, що встигло прийти, лишається
    expect(parts, ['Ось 5 пунктів']);
  });

  test('повідомлення з помилкою не йдуть в історію запиту', () async {
    late Map body;
    final client = MockClient((request) async {
      body = jsonDecode(request.body) as Map;
      return http.Response(_answer('ok'), 200);
    });
    final service = GeminiService(apiKey: 'k', client: client);
    await service.generate([
      ChatMessage(role: ChatRole.user, text: 'a'),
      ChatMessage(role: ChatRole.model, text: 'помилка', isError: true),
      ChatMessage(role: ChatRole.user, text: 'b'),
    ]);
    expect((body['contents'] as List).length, 2);
  });
}
