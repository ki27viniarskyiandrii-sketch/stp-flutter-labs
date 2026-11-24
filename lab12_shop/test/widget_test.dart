import 'package:flutter_test/flutter_test.dart';
import 'package:lab12_shop/data/auth_repository.dart';
import 'package:lab12_shop/data/order_repository.dart';
import 'package:lab12_shop/main.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('повний сценарій: вхід, кошик, замовлення', (tester) async {
    await tester.pumpWidget(ShopApp(
      authRepository: DemoAuthRepository(),
      orderRepository: DemoOrderRepository(),
    ));

    await tester.enterText(find.byType(TextField).at(0), 'andrii@vtfk.ua');
    await tester.enterText(find.byType(TextField).at(1), 'student123');
    await tester.tap(find.text('Увійти'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Каталог'), findsOneWidget);
    await tester.tap(find.byTooltip('Додати Зошит А4'));
    await tester.tap(find.byTooltip('Додати Ручка гелева'));
    await tester.pump();
    expect(find.text('Кошик (2)'), findsOneWidget);

    await tester.tap(find.text('Кошик (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Разом: 65 грн'), findsOneWidget);

    await tester.tap(find.text('Оформити замовлення'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Замовлення оформлено'), findsOneWidget);
  });
}
