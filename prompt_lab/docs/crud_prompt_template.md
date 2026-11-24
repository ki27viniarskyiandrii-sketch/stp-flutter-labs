# Шаблон промпту: CRUD-екран для сутності

```
Роль: ти Flutter-розробник у проєкті {{PROJECT}}, пишеш код у стилі наявних файлів.

Контекст:
- Flutter {{FLUTTER_VERSION}}, UI імпортую через {{UI_IMPORT}}.
- Керування станом: {{STATE}}.
- Джерело даних: {{DATA_SOURCE}}.
- Приклади наших файлів (стиль і назви): {{EXAMPLES}}.

Задача: зроби CRUD для сутності {{ENTITY}} ({{ENTITY_UA}}).
Поля (назва: тип, обов'язкове чи ні, правило перевірки):
{{FIELDS}}

Що потрібно:
1. Модель {{ENTITY}} у lib/models/{{entity_file}}.dart з fromJson, toJson, copyWith.
2. {{ENTITY}}Repository з методами getAll, getById, create, update, delete.
3. Стан {{ENTITY}}{{STATE_SUFFIX}}: завантаження, помилка, список.
4. {{ENTITY}}ListScreen: список, порожній стан, pull-to-refresh, видалення з підтвердженням.
5. {{ENTITY}}FormScreen: створення і редагування в одній формі, перевірка полів.

Обмеження: {{CONSTRAINTS}}

Формат відповіді: спочатку список файлів, потім код кожного файлу окремим
блоком без скорочень, наприкінці перелік місць, де ти не впевнений в API.
```

## Плейсхолдери

| Плейсхолдер | Що підставляти | Приклад |
|---|---|---|
| `{{PROJECT}}` | назва проєкту | prompt_lab |
| `{{FLUTTER_VERSION}}` | версія з `flutter --version` | 3.50.1 |
| `{{UI_IMPORT}}` | бібліотека віджетів | package:material_ui/material_ui.dart |
| `{{STATE}}` | підхід до стану | provider (ChangeNotifier) |
| `{{DATA_SOURCE}}` | звідки дані | ApiService на Dio, базова адреса https://dummyjson.com |
| `{{EXAMPLES}}` | 1-2 файли-зразки | custom_text_field.dart, task_provider.dart |
| `{{ENTITY}}` | назва класу | Course |
| `{{ENTITY_UA}}` | назва українською | навчальний курс |
| `{{entity_file}}` | назва файлу | course |
| `{{FIELDS}}` | поля з правилами | title: String, обов'язкове, 3-100 символів |
| `{{STATE_SUFFIX}}` | суфікс класу стану | Provider або Cubit |
| `{{CONSTRAINTS}}` | обмеження | без нових пакетів, const де можна, dispose() контролерів, тексти українською |

## Приклад заповнення

```
{{ENTITY}} = Course, {{ENTITY_UA}} = навчальний курс
{{FIELDS}} =
  title: String, обов'язкове, 3-100 символів
  teacher: String, обов'язкове
  hours: int, обов'язкове, від 1 до 200
  isExam: bool, необов'язкове, за замовчуванням false
{{STATE}} = provider (ChangeNotifier), {{STATE_SUFFIX}} = Provider
```

Щоб перейти на інший підхід до стану, міняю `{{STATE}}` і `{{STATE_SUFFIX}}`
(наприклад flutter_bloc і Cubit) і даю в `{{EXAMPLES}}` один наш Cubit як зразок.
Для іншої сутності міняю тільки `{{ENTITY}}`, `{{ENTITY_UA}}`, `{{entity_file}}` і `{{FIELDS}}`.
