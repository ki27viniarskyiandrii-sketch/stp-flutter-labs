import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_lab/widgets/custom_dropdown.dart';

void main() {
  testWidgets('CustomDropdown показує підпис і передає вибране значення',
      (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomDropdown<String>(
            label: 'Група',
            items: const ['4КІ1', '4КІ2', '4КІ3'],
            itemLabel: (s) => s,
            onChanged: (v) => selected = v,
          ),
        ),
      ),
    );

    expect(find.text('Група'), findsOneWidget);

    await tester.tap(find.byType(CustomDropdown<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4КІ3').last);
    await tester.pumpAndSettle();

    expect(selected, '4КІ3');
  });
}
