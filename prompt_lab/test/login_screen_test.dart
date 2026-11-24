import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_lab/models/user.dart';
import 'package:prompt_lab/providers/auth_provider.dart';
import 'package:prompt_lab/screens/login_screen.dart';
import 'package:prompt_lab/services/api_service.dart';
import 'package:provider/provider.dart';

/// Сервіс без мережі: пароль 123456 правильний, інші ні.
class FakeApiService extends ApiService {
  @override
  Future<User> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (password != '123456') {
      throw const ApiException('Invalid credentials (400)', statusCode: 400);
    }
    return const User(
      id: 1,
      username: 'test',
      email: 'test@mail.com',
      firstName: 'Тест',
      lastName: 'Користувач',
    );
  }
}

Widget _app() => ChangeNotifierProvider(
      create: (_) => AuthProvider(FakeApiService()),
      child: const MaterialApp(home: LoginScreen()),
    );

void main() {
  testWidgets('порожня форма показує помилки під полями', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Увійти'));
    await tester.pump();

    expect(find.text('Введіть email'), findsOneWidget);
    expect(find.text('Введіть пароль'), findsOneWidget);
  });

  testWidgets('неправильний email і короткий пароль', (tester) async {
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(0), 'abc');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.text('Увійти'));
    await tester.pump();

    expect(find.text('Невірний формат email'), findsOneWidget);
    expect(
      find.text('Пароль має бути не коротший за 6 символів'),
      findsOneWidget,
    );
  });

  testWidgets('під час запиту крутиться індикатор, потім вітання', (tester) async {
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(0), 'test@mail.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Увійти'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.text('Вітаю, Тест Користувач!'), findsOneWidget);
  });

  testWidgets('помилка сервера показується у SnackBar', (tester) async {
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(0), 'test@mail.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-pass');
    await tester.tap(find.text('Увійти'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Invalid credentials (400)'), findsOneWidget);
  });

  testWidgets('кнопка з оком показує пароль', (tester) async {
    await tester.pumpWidget(_app());
    final field = find.descendant(
      of: find.byType(TextFormField).at(1),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(field).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(tester.widget<EditableText>(field).obscureText, isFalse);
  });
}
