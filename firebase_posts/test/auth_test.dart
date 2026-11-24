import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_posts/data/auth_repository.dart';
import 'package:firebase_posts/data/posts_repository.dart';
import 'package:firebase_posts/screens/auth_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Підробка без Firebase: вхід завжди відхиляється, реєстрація рахується.
class FakeAuth implements AuthRepository {
  int signUpCalls = 0;

  @override
  Stream<User?> authStateChanges() => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  Future<User> signIn(String email, String password) async =>
      throw const AuthFailure('Невірний email або пароль');

  @override
  Future<User> signUp(String email, String password) async {
    signUpCalls++;
    throw const AuthFailure('Акаунт з таким email вже існує');
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  group('тексти помилок', () {
    test('коди FirebaseAuthException', () {
      expect(authErrorMessage('invalid-credential'), 'Невірний email або пароль');
      expect(authErrorMessage('wrong-password'), 'Невірний email або пароль');
      expect(authErrorMessage('email-already-in-use'), 'Акаунт з таким email вже існує');
      expect(authErrorMessage('weak-password'), contains('6 символів'));
      expect(authErrorMessage('щось-нове'), contains('щось-нове'));
    });

    test('permission-denied з Firestore', () {
      expect(firestoreErrorMessage('permission-denied'), contains('лише його автор'));
    });
  });

  Future<void> pump(WidgetTester tester, FakeAuth auth) =>
      tester.pumpWidget(MaterialApp(home: AuthScreen(auth: auth)));

  testWidgets('неправильний email і короткий пароль не відправляються', (tester) async {
    final auth = FakeAuth();
    await pump(tester, auth);
    await tester.enterText(find.byType(TextFormField).at(0), 'andrii-vtfk.ua');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.widgetWithText(FilledButton, 'Увійти'));
    await tester.pump();
    expect(find.text('Невірний формат email'), findsOneWidget);
    expect(find.text('Мінімум 6 символів'), findsOneWidget);
  });

  testWidgets('помилка входу показується в SnackBar', (tester) async {
    await pump(tester, FakeAuth());
    await tester.enterText(find.byType(TextFormField).at(0), 'andrii@vtfk.ua');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret12');
    await tester.tap(find.widgetWithText(FilledButton, 'Увійти'));
    await tester.pumpAndSettle();
    expect(find.text('Невірний email або пароль'), findsOneWidget);
  });

  testWidgets('реєстрація перевіряє повтор пароля', (tester) async {
    final auth = FakeAuth();
    await pump(tester, auth);
    await tester.tap(find.text('Немає акаунта? Зареєструватися'));
    await tester.pump();
    expect(find.text('Реєстрація'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'andrii@vtfk.ua');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret12');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret13');
    await tester.tap(find.widgetWithText(FilledButton, 'Зареєструватися'));
    await tester.pump();
    expect(find.text('Паролі не збігаються'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });
}
