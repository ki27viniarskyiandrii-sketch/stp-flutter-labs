import 'package:material_ui/material_ui.dart';

import '../models/chat_message.dart';

/// Бульбашка повідомлення: користувач праворуч, модель ліворуч.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;
    final background = message.isError
        ? scheme.errorContainer
        : isUser
            ? scheme.primary
            : scheme.surfaceContainerHighest;
    final foreground = message.isError
        ? scheme.onErrorContainer
        : isUser
            ? scheme.onPrimary
            : scheme.onSurface;
    final time = TimeOfDay.fromDateTime(message.time).format(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                message.text.isEmpty ? '...' : message.text,
                style: TextStyle(color: foreground, height: 1.35),
              ),
              const SizedBox(height: 4),
              Text(
                '${isUser ? 'Я' : 'Gemini'}, $time',
                style: TextStyle(
                  color: foreground.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
