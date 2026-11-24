import 'package:material_ui/material_ui.dart';

/// Картка профілю користувача.
///
/// Віджет нічого не знає про API чи моделі даних: отримує вже готові
/// значення, тому його легко перевикористати і протестувати.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.fullName,
    required this.email,
    this.phone,
    this.city,
    this.avatarUrl,
    this.onTap,
  });

  final String fullName;
  final String email;
  final String? phone;
  final String? city;
  final String? avatarUrl;
  final VoidCallback? onTap;

  String get _initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Avatar(url: avatarUrl, initials: _initials),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.email_outlined, text: email),
                    if (phone != null && phone!.isNotEmpty)
                      _InfoRow(icon: Icons.phone_outlined, text: phone!),
                    if (city != null && city!.isNotEmpty)
                      _InfoRow(icon: Icons.location_on_outlined, text: city!),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.initials});

  final String? url;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fallback = CircleAvatar(
      radius: 36,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 22),
      ),
    );
    if (url == null || url!.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        url!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
