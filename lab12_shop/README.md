# lab12_shop (ЛР12)

Автоматизоване тестування Flutter-застосунку з AI. Вінярський Андрій, 4КІ3.

Сценарії: вхід (LoginCubit) і оформлення замовлення (CartCubit).

| Що | Де |
|---|---|
| Тест-кейси Gherkin (чернетка AI і після перевірки) | `docs/test_cases_ai_draft.feature`, `docs/test_cases.feature` |
| Промпти до AI | `docs/AI_PROMPTS.md` |
| Unit-тести Cubit (bloc_test, mocktail) | `test/login_cubit_test.dart`, `test/cart_cubit_test.dart` |
| Widget-тест повного сценарію | `test/widget_test.dart` |
| E2E Maestro | `.maestro/` |
| CI | `../.github/workflows/lab12_tests.yml` |

Демо-вхід: будь-який правильний email і пароль `student123`.

```
flutter pub get
flutter test
flutter build apk --debug
maestro test .maestro/
```

E2E сценарії Maestro запускаються в GitHub Actions на кожен pull request.
