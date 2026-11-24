# gemini_chat_app (ЛР10)

AI-чат на Flutter з Gemini API. Вінярський Андрій, 4КІ3.

- `lib/services/gemini_service.dart`: запити `generateContent` і `streamGenerateContent?alt=sse`, обробка 400, 401/403, 404, 429, 5xx, тайм-ауту і відсутності мережі.
- `lib/models/chat_message.dart`: повідомлення (текст, роль user/model, час).
- `lib/screens/chat_screen.dart`: чат, перемикач стрімінгу, очищення історії, індикатор завантаження.
- `lib/utils/format_text.dart`: базове форматування відповіді.

## Ключ

Ключ не зберігається в репозиторії. Скопіюйте `.env.example` у `.env` і вставте свій ключ з https://aistudio.google.com/apikey:

```
GEMINI_API_KEY=ваш_ключ
GEMINI_MODEL=gemini-3.5-flash-lite
```

`.env` додано в `.gitignore`.

## Запуск

```
flutter pub get
flutter test
flutter run -d chrome
```
