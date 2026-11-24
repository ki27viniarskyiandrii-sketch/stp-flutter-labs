# prompt_lab (ЛР7)

Лабораторна робота 7 «Prompt engineering». Вінярський Андрій, 4КІ3.

Застосунок збирає результати всіх промптів на одному головному екрані:

1. Поганий промпт: `lib/variants/bad_login_screen.dart`
2. Хороший промпт: `lib/screens/login_screen.dart`, `lib/providers/auth_provider.dart`
3. Few-shot: `lib/widgets/custom_dropdown.dart` (зразки `custom_button.dart`, `custom_text_field.dart`)
4. Chain-of-thought: `lib/models/task.dart`, `lib/providers/task_provider.dart`, `lib/screens/task_list_screen.dart`
5. Рольовий промпт: `lib/variants/profile_card_basic.dart` і `lib/widgets/profile_card.dart`
6. Контекст файлів: `fetchUserProfile()` у `lib/services/api_service.dart`, `lib/models/user_profile.dart`; без контексту: `drafts/api_service_no_context.dart`

Промпти, таблиця оцінок і галюцинації: `docs/PROMPTS.md`. Шаблон CRUD-промпту: `docs/crud_prompt_template.md`.

## Запуск

```
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Дані профілю беруться з https://dummyjson.com.
