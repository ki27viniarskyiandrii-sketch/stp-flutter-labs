# Промпти ЛР7 і результати

AI-асистент: Claude. Flutter 3.50.1, Dart 3.14.0.

## 1. Поганий промпт

```
Зроби екран логіну на Flutter
```

Результат: `lib/variants/bad_login_screen.dart`. Один файл з `main()` і `MyApp`, `TextField` без `Form`, перевірка тільки на порожні поля, пароль друкується через `print`, контролери не звільняються, `ElevatedButton` і `primarySwatch` (стиль Material 2).

## 2. Хороший промпт

```
Роль: ти Flutter-розробник, який працює за принципами Clean Architecture.
Контекст: проєкт prompt_lab на Flutter 3, Material 3, стан через provider
(ChangeNotifier). У проєкті вже є ApiService з методом login(email, password),
який повертає User або кидає ApiException(message).
Задача: створи екран LoginScreen (StatefulWidget) з полями email і пароль
та клас AuthProvider (ChangeNotifier) зі станами isLoading, errorMessage і user.
Обмеження: валідація email регулярним виразом, пароль не коротший за 6 символів,
помилки під полями, кнопка FilledButton з CircularProgressIndicator під час
запиту (кнопка неактивна), приховування пароля через IconButton, помилку
сервера показати у SnackBar, контролери звільнити в dispose(), без нових пакетів.
Формат відповіді: спочатку коротко структура файлів, потім повний код кожного
файлу окремим блоком, без скорочень.
```

Результат: `lib/screens/login_screen.dart`, `lib/providers/auth_provider.dart`.

## 3. Few-shot

```
Ось приклади стилю кодування нашого проєкту:
[код lib/widgets/custom_button.dart]
[код lib/widgets/custom_text_field.dart]
За аналогією до цього стилю (іменування, const-конструктор, super.key, поля
final після конструктора, InputDecoration з OutlineInputBorder) створи новий
віджет CustomDropdown<T> з такими ж параметрами: label, hint, icon, validator,
enabled, а також items, itemLabel, value, onChanged.
```

Результат: `lib/widgets/custom_dropdown.dart`.

## 4. Chain-of-thought

```
Крок 1: опиши план реалізації екрана «Список завдань» (ToDo): які файли
потрібні, яка модель даних, який підхід до керування станом, які пакети
pub.dev знадобляться. Код поки не пиши.
Крок 2: після того як я погоджу план, згенеруй код кожного файлу окремо:
спочатку модель Task, потім TaskProvider, потім TaskListScreen.
```

План від AI:

1. `lib/models/task.dart`: Task (id, title, priority, isDone, createdAt), enum TaskPriority з підписами, copyWith.
2. `lib/providers/task_provider.dart`: TaskProvider (ChangeNotifier), фільтр усі/активні/виконані, addTask (порожню назву не приймає), toggleTask, removeTask, лічильники.
3. `lib/screens/task_list_screen.dart`: лічильник в AppBar, SegmentedButton для фільтра, CheckboxListTile, видалення свайпом, FAB з діалогом.
4. `main.dart`: ChangeNotifierProvider для TaskProvider.
5. Пакети: provider, uuid.

Моє уточнення до плану: «id через uuid v4, діалог додавання окремим приватним віджетом з dispose()».

## 5. Рольовий промпт

Базовий:

```
Напиши віджет картки профілю користувача для Flutter-застосунку:
фото, ім'я, email, телефон, місто.
```

Рольовий:

```
Ти senior Flutter-розробник з 10-річним досвідом, що дотримується clean
architecture. Напиши віджет картки профілю користувача для Flutter-застосунку:
фото, ім'я, email, телефон, місто.
```

Результати: `lib/variants/profile_card_basic.dart` і `lib/widgets/profile_card.dart`.

## 6. Контекст файлів проєкту

З контекстом:

```
Ось файли проєкту:
pubspec.yaml: [вміст]
lib/models/user.dart: [вміст]
lib/services/api_service.dart: [вміст]
На основі наведеного ApiService згенеруй новий метод fetchUserProfile(int id),
який використовує той самий Dio-клієнт, той самий формат обробки помилок
(try-catch з DioException і _toApiException) і повертає модель UserProfile
з GET /users/{id}. Модель UserProfile зроби окремим файлом
lib/models/user_profile.dart.
```

Без контексту:

```
Додай у наш ApiService метод fetchUserProfile(), який використовує Dio
і повертає модель UserProfile.
```

Результати: `lib/services/api_service.dart` (з контекстом) і `drafts/api_service_no_context.dart` (без контексту, виключений з аналізу).

## Таблиця порівняння

| № | Мета | Техніка | Оцінка | Коментар |
|---|---|---|---|---|
| 1 | Екран логіну | без структури | 2 | без Form і перевірки email, print пароля, без dispose(), стиль M2 |
| 2 | Екран логіну | роль, контекст, задача, обмеження, формат | 5 | усе з вимог, 5 тестів пройшли, змінив тільки імпорт |
| 3 | CustomDropdown | few-shot | 4 | стиль збігся, але застарілий параметр value |
| 4 | Список завдань | chain-of-thought | 5 | план без зайвого, 5 тестів TaskProvider пройшли |
| 5а | ProfileCard | без ролі | 3 | без key і const, сірі кольори в коді, без обробки помилки фото |
| 5б | ProfileCard | рольовий | 5 | const, тема, ініціали без фото, errorBuilder, ellipsis |
| 6а | fetchUserProfile | з файлами | 5 | той самий _dio і _toApiException, працює з API |
| 6б | fetchUserProfile | без файлів | 1 | 4 помилки компіляції, вигаданий шлях /user/profile |

## Галюцинації

1. Застарілий імпорт `package:flutter/material.dart` у кожному файлі. У Flutter 3.50 він deprecated з 3.47, шаблон `flutter create` уже використовує `package:material_ui/material_ui.dart`. Виявив через `flutter analyze` і через падіння `No MaterialLocalizations found`. Виправив заміною імпорту.
2. `DropdownButtonFormField(value: ...)` застарів з 3.33. Замінив на `initialValue`.
3. Без контексту AI вигадав `_tokenStorage`, `ApiException.fromDioError`, іменований параметр `message` і шлях `/user/profile` (сервер повертає 400 «Invalid user id 'profile'»).
