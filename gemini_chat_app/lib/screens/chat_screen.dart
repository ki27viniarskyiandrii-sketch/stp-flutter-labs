import 'package:material_ui/material_ui.dart';

import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../utils/format_text.dart';
import '../widgets/message_bubble.dart';

/// Екран чату з Gemini.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.service});

  final GeminiService service;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <ChatMessage>[];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _isLoading = false;
  bool _useStream = true;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, text: text));
      _input.clear();
      _isLoading = true;
    });
    _scrollToEnd();

    final history = List<ChatMessage>.of(_messages);
    try {
      if (_useStream) {
        await _receiveStream(history);
      } else {
        final answer = await widget.service.generate(history);
        setState(() {
          _messages.add(
            ChatMessage(role: ChatRole.model, text: formatModelText(answer)),
          );
        });
      }
    } on GeminiException catch (e) {
      _showError(e.message);
    } catch (e) {
      // щоб чат не завис на крутилці через непередбачену помилку
      _showError('Неочікувана помилка: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToEnd();
    }
  }

  /// Додаю порожню бульбашку і дописую в неї кожну частину відповіді.
  Future<void> _receiveStream(List<ChatMessage> history) async {
    final buffer = StringBuffer();
    setState(() => _messages.add(ChatMessage(role: ChatRole.model, text: '')));
    final index = _messages.length - 1;
    try {
      await for (final chunk in widget.service.generateStream(history)) {
        buffer.write(chunk);
        setState(() {
          _messages[index] = _messages[index].copyWith(text: buffer.toString());
        });
        _scrollToEnd();
      }
      setState(() {
        _messages[index] =
            _messages[index].copyWith(text: formatModelText(buffer.toString()));
      });
    } catch (_) {
      // порожню бульбашку прибираю, помилку покаже _send
      if (buffer.isEmpty) setState(() => _messages.removeAt(index));
      rethrow;
    }
  }

  void _showError(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(role: ChatRole.model, text: text, isError: true));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистити чат?'),
        content: const Text('Уся історія повідомлень буде видалена.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Очистити'),
          ),
        ],
      ),
    );
    if (ok == true) setState(_messages.clear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat'),
        actions: [
          Tooltip(
            message: _useStream ? 'Режим: стрімінг' : 'Режим: одна відповідь',
            child: Row(
              children: [
                const Text('Стрім'),
                Switch(
                  value: _useStream,
                  onChanged: _isLoading
                      ? null
                      : (v) => setState(() => _useStream = v),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Очистити історію',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _messages.isEmpty || _isLoading ? null : _clear,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Напишіть перше повідомлення'))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) =>
                        MessageBubble(message: _messages[i]),
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      enabled: !_isLoading,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Повідомлення для Gemini',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Надіслати',
                    icon: const Icon(Icons.send),
                    onPressed: _isLoading ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
