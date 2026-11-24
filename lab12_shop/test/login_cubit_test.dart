import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab12_shop/data/auth_repository.dart';
import 'package:lab12_shop/logic/login_cubit.dart';
import 'package:lab12_shop/models/models.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  const user = User(email: 'andrii@vtfk.ua', name: 'andrii');

  setUp(() => repository = MockAuthRepository());

  test('початковий стан initial', () {
    expect(LoginCubit(repository).state, const LoginState());
  });

  blocTest<LoginCubit, LoginState>(
    'успішний вхід: loading, потім success з користувачем',
    setUp: () => when(() => repository.signIn('andrii@vtfk.ua', 'student123'))
        .thenAnswer((_) async => user),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.signIn('  andrii@vtfk.ua ', 'student123'),
    expect: () => const [
      LoginState(status: LoginStatus.loading),
      LoginState(status: LoginStatus.success, user: user),
    ],
    verify: (_) => verify(() => repository.signIn('andrii@vtfk.ua', 'student123')).called(1),
  );

  blocTest<LoginCubit, LoginState>(
    'неправильний пароль: loading, потім failure з текстом сервера',
    setUp: () => when(() => repository.signIn(any(), any()))
        .thenThrow(const AuthException('Невірний email або пароль')),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.signIn('andrii@vtfk.ua', 'wrong-pass'),
    expect: () => const [
      LoginState(status: LoginStatus.loading),
      LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Невірний email або пароль',
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'невідома помилка репозиторію дає загальне повідомлення',
    setUp: () => when(() => repository.signIn(any(), any()))
        .thenThrow(Exception('timeout')),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.signIn('andrii@vtfk.ua', 'student123'),
    expect: () => const [
      LoginState(status: LoginStatus.loading),
      LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Не вдалося увійти, спробуйте ще раз',
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'неправильний email: одразу failure, репозиторій не викликається',
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.signIn('andrii-vtfk.ua', 'student123'),
    expect: () => const [
      LoginState(status: LoginStatus.failure, errorMessage: 'Невірний формат email'),
    ],
    verify: (_) => verifyNever(() => repository.signIn(any(), any())),
  );

  blocTest<LoginCubit, LoginState>(
    'граничний випадок: пароль з 5 символів не проходить, з 6 проходить',
    setUp: () => when(() => repository.signIn(any(), any()))
        .thenAnswer((_) async => user),
    build: () => LoginCubit(repository),
    act: (cubit) async {
      await cubit.signIn('andrii@vtfk.ua', '12345');
      await cubit.signIn('andrii@vtfk.ua', '123456');
    },
    expect: () => const [
      LoginState(
        status: LoginStatus.failure,
        errorMessage: 'Пароль має бути не коротший за 6 символів',
      ),
      LoginState(status: LoginStatus.loading),
      LoginState(status: LoginStatus.success, user: user),
    ],
  );
}
