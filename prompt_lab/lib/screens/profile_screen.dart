import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../widgets/profile_card.dart';

/// Профіль з сервера: ApiService.fetchUserProfile() + ProfileCard.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _userId = 1;
  late Future<UserProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<UserProfile> _load() =>
      context.read<ApiService>().fetchUserProfile(_userId);

  void _next(int delta) {
    setState(() {
      _userId = (_userId + delta).clamp(1, 208);
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль з API')),
      body: FutureBuilder<UserProfile>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${snapshot.error}'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _next(0),
                    child: const Text('Повторити'),
                  ),
                ],
              ),
            );
          }
          final p = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileCard(
                fullName: p.fullName,
                email: p.email,
                phone: p.phone,
                city: p.city,
                avatarUrl: p.image,
              ),
              const SizedBox(height: 8),
              Text('id: ${p.id}, посада: ${p.companyTitle ?? '-'}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _userId > 1 ? () => _next(-1) : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Попередній'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _next(1),
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Наступний'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
