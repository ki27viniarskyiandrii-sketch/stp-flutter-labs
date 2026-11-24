import 'package:material_ui/material_ui.dart';

import '../variants/bad_login_screen.dart' as bad;
import 'dropdown_demo_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'role_compare_screen.dart';
import 'task_list_screen.dart';

/// Головний екран: результати кожного промпту.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String, IconData, Widget)>[
      ('1. Поганий промпт', 'LoginScreen без вимог', Icons.thumb_down_outlined, const bad.LoginScreen()),
      ('2. Хороший промпт', 'LoginScreen + AuthProvider', Icons.thumb_up_outlined, const LoginScreen()),
      ('3. Few-shot', 'CustomDropdown у стилі проєкту', Icons.copy_all_outlined, const DropdownDemoScreen()),
      ('4. Chain-of-thought', 'Список завдань (Task, TaskProvider)', Icons.checklist, const TaskListScreen()),
      ('5. Рольовий промпт', 'ProfileCard: база і senior', Icons.badge_outlined, const RoleCompareScreen()),
      ('6. Контекст файлів', 'fetchUserProfile() через наявний Dio', Icons.cloud_download_outlined, const ProfileScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('prompt_lab')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final (title, subtitle, icon, screen) = items[i];
          return Card(
            child: ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => screen),
              ),
            ),
          );
        },
      ),
    );
  }
}
