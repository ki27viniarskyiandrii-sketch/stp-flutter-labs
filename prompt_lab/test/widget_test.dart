import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_lab/main.dart';

void main() {
  testWidgets('головний екран показує всі 6 варіантів промптів', (tester) async {
    await tester.pumpWidget(const PromptLabApp());

    expect(find.text('prompt_lab'), findsOneWidget);
    expect(find.text('1. Поганий промпт'), findsOneWidget);
    expect(find.text('2. Хороший промпт'), findsOneWidget);
    expect(find.text('6. Контекст файлів'), findsOneWidget);
  });
}
