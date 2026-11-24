import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_chat_app/utils/format_text.dart';

void main() {
  test('прибирає зайві пробіли і порожні рядки', () {
    expect(formatModelText('  Рядок 1   \r\n\n\n\nРядок 2  \n'), 'Рядок 1\n\nРядок 2');
  });
}
