import 'package:material_ui/material_ui.dart';

import '../data/auth_repository.dart';

/// Один екран для входу і реєстрації, перемикається кнопкою внизу.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.auth});

  final AuthRepository auth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;

  static final _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isSignUp) {
        await widget.auth.signUp(_email.text, _password.text);
      } else {
        await widget.auth.signIn(_email.text, _password.text);
      }
      // далі екран сам зміниться через authStateChanges()
    } on AuthFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Реєстрація' : 'Вхід')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.forum_outlined, size: 56),
                const SizedBox(height: 8),
                Text('Студентські записи',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _emailRegExp.hasMatch((v ?? '').trim())
                      ? null
                      : 'Невірний формат email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  enabled: !_loading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v ?? '').length >= 6 ? null : 'Мінімум 6 символів',
                ),
                if (_isSignUp) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password2,
                    enabled: !_loading,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Повторіть пароль',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == _password.text ? null : 'Паролі не збігаються',
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isSignUp ? 'Зареєструватися' : 'Увійти'),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp
                      ? 'Вже є акаунт? Увійти'
                      : 'Немає акаунта? Зареєструватися'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
