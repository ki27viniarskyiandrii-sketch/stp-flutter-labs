import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import '../models/models.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.errorMessage,
  });

  final LoginStatus status;
  final User? user;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, user, errorMessage];
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  static final _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  Future<void> signIn(String email, String password) async {
    final trimmed = email.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      emit(const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Невірний формат email',
      ));
      return;
    }
    if (password.length < 6) {
      emit(const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Пароль має бути не коротший за 6 символів',
      ));
      return;
    }

    emit(const LoginState(status: LoginStatus.loading));
    try {
      final user = await _repository.signIn(trimmed, password);
      emit(LoginState(status: LoginStatus.success, user: user));
    } on AuthException catch (e) {
      emit(LoginState(status: LoginStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(const LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Не вдалося увійти, спробуйте ще раз',
      ));
    }
  }
}
