import 'package:material_ui/material_ui.dart';

import '../variants/profile_card_basic.dart' as basic;
import '../widgets/profile_card.dart';

/// Порівняння: картка з базового промпту і з рольового.
class RoleCompareScreen extends StatelessWidget {
  const RoleCompareScreen({super.key});

  static const _photo = 'https://dummyjson.com/icon/emilys/128';

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Рольовий промпт')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Базовий промпт', style: style),
          basic.ProfileCard(
            name: 'Emily Johnson',
            email: 'emily.johnson@x.dummyjson.com',
            phone: '+81 965-431-3024',
            city: 'Phoenix',
            photoUrl: _photo,
          ),
          const SizedBox(height: 16),
          Text('Рольовий промпт (senior, clean architecture)', style: style),
          const ProfileCard(
            fullName: 'Emily Johnson',
            email: 'emily.johnson@x.dummyjson.com',
            phone: '+81 965-431-3024',
            city: 'Phoenix',
            avatarUrl: _photo,
          ),
          const SizedBox(height: 8),
          const ProfileCard(
            fullName: 'Андрій Вінярський',
            email: 'andrii@example.com',
          ),
        ],
      ),
    );
  }
}
