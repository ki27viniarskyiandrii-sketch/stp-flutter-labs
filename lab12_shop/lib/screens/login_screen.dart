import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../logic/login_cubit.dart';
import 'catalog_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => CatalogScreen(user: state.user!)),
          );
        }
      },
      builder: (context, state) {
        final loading = state.status == LoginStatus.loading;
        return Scaffold(
          appBar: AppBar(title: const Text('Вхід')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Semantics(
                identifier: 'email_field',
                child: TextField(
                  controller: _email,
                  enabled: !loading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                identifier: 'password_field',
                child: TextField(
                  controller: _password,
                  enabled: !loading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (state.status == LoginStatus.failure)
                Text(
                  state.errorMessage ?? '',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 12),
              Semantics(
                identifier: 'login_button',
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : () => context
                          .read<LoginCubit>()
                          .signIn(_email.text, _password.text),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Увійти'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
