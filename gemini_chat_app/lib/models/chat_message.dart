/// Хто написав повідомлення.
enum ChatRole { user, model }

/// Одне повідомлення в історії чату.
class ChatMessage {
  ChatMessage({
    required this.role,
    required this.text,
    DateTime? time,
    this.isError = false,
  }) : time = time ?? DateTime.now();

  final ChatRole role;
  final String text;
  final DateTime time;

  /// Повідомлення з помилкою показується в чаті, але не йде в історію запиту.
  final bool isError;

  bool get isUser => role == ChatRole.user;

  ChatMessage copyWith({String? text, bool? isError}) => ChatMessage(
        role: role,
        text: text ?? this.text,
        time: time,
        isError: isError ?? this.isError,
      );

  /// Формат одного елемента масиву contents у запиті до Gemini.
  Map<String, dynamic> toContent() => {
        'role': role.name,
        'parts': [
          {'text': text},
        ],
      };
}
