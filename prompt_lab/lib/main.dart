import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const PromptLabApp());
}

class PromptLabApp extends StatelessWidget {
  const PromptLabApp({super.key, this.api});

  /// У тестах сюди передаю фейковий сервіс.
  final ApiService? api;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => api ?? ApiService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'prompt_lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
