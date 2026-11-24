import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_chat_app/main.dart';
import 'package:gemini_chat_app/models/chat_message.dart';
import 'package:gemini_chat_app/services/gemini_service.dart';
import 'package:material_ui/material_ui.dart';

class FakeGemini extends GeminiService {
  FakeGemini() : super(apiKey: 'test');

  bool fail = false;

  @override
  Stream<String> generateStream(List<ChatMessage> history) async* {
    if (fail) {
      throw const GeminiException('Перевищено ліміт (429)', statusCode: 429);
    }
    yield 'Відповідь ';
    await Future<void>.delayed(const Duration(milliseconds: 50));
    yield 'частинами';
  }
}

void main() {
  testWidgets('надсилання повідомлення і стрімінгова відповідь', (tester) async {
    await tester.pumpWidget(GeminiChatApp(service: FakeGemini()));
    expect(find.text('Напишіть перше повідомлення'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Привіт');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    expect(find.text('Привіт'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.text('Відповідь частинами'), findsOneWidget);
  });

  testWidgets('помилка 429 показується в SnackBar', (tester) async {
    final fake = FakeGemini()..fail = true;
    await tester.pumpWidget(GeminiChatApp(service: fake));
    await tester.enterText(find.byType(TextField), 'Тест');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    expect(find.text('Перевищено ліміт (429)'), findsWidgets);
  });
}
