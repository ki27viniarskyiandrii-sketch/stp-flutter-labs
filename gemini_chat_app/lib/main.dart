import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:material_ui/material_ui.dart';

import 'screens/chat_screen.dart';
import 'services/gemini_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ключ лежить у .env, який не потрапляє в git
  await dotenv.load(fileName: '.env');
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final model = dotenv.env['GEMINI_MODEL'] ?? 'gemini-3.5-flash-lite';
  runApp(GeminiChatApp(service: GeminiService(apiKey: apiKey, model: model)));
}

class GeminiChatApp extends StatelessWidget {
  const GeminiChatApp({super.key, required this.service});

  final GeminiService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: ChatScreen(service: service),
    );
  }
}
