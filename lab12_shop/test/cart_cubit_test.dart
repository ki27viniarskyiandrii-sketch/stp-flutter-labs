import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab12_shop/data/order_repository.dart';
import 'package:lab12_shop/logic/cart_cubit.dart';
import 'package:lab12_shop/models/models.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository orders;
  final notebook = demoProducts[0]; // 45 грн
  final pen = demoProducts[1]; // 20 грн

  setUpAll(() => registerFallbackValue(<Product, int>{}));
  setUp(() => orders = MockOrderRepository());

  blocTest<CartCubit, CartState>(
    'додавання товарів рахує кількість і суму',
    build: () => CartCubit(orders),
    act: (cubit) => cubit
      ..add(notebook)
      ..add(notebook)
      ..add(pen),
    skip: 2,
    expect: () => [
      isA<CartState>()
          .having((s) => s.count, 'count', 3)
          .having((s) => s.total, 'total', 110),
    ],
  );

  blocTest<CartCubit, CartState>(
    'remove зменшує кількість, а на нулі прибирає товар',
    build: () => CartCubit(orders),
    seed: () => CartState(items: {notebook: 2, pen: 1}),
    act: (cubit) => cubit
      ..remove(notebook)
      ..remove(pen),
    expect: () => [
      CartState(items: {notebook: 1, pen: 1}),
      CartState(items: {notebook: 1}),
    ],
  );

  blocTest<CartCubit, CartState>(
    'оформлення: submitting, потім success з номером і порожнім кошиком',
    setUp: () => when(() => orders.placeOrder(any()))
        .thenAnswer((_) async => 'ORD-1001'),
    build: () => CartCubit(orders),
    seed: () => CartState(items: {pen: 2}),
    act: (cubit) => cubit.checkout(),
    expect: () => [
      CartState(items: {pen: 2}, status: CheckoutStatus.submitting),
      const CartState(status: CheckoutStatus.success, orderId: 'ORD-1001'),
    ],
    verify: (_) => verify(() => orders.placeOrder({pen: 2})).called(1),
  );

  blocTest<CartCubit, CartState>(
    'помилка сервера при оформленні зберігає товари в кошику',
    setUp: () => when(() => orders.placeOrder(any()))
        .thenThrow(const OrderException('Сервер недоступний')),
    build: () => CartCubit(orders),
    seed: () => CartState(items: {pen: 1}),
    act: (cubit) => cubit.checkout(),
    expect: () => [
      CartState(items: {pen: 1}, status: CheckoutStatus.submitting),
      CartState(
        items: {pen: 1},
        status: CheckoutStatus.failure,
        errorMessage: 'Сервер недоступний',
      ),
    ],
  );

  blocTest<CartCubit, CartState>(
    'порожній кошик: failure і сервер не викликається',
    build: () => CartCubit(orders),
    act: (cubit) => cubit.checkout(),
    expect: () => const [
      CartState(status: CheckoutStatus.failure, errorMessage: 'Кошик порожній'),
    ],
    verify: (_) => verifyNever(() => orders.placeOrder(any())),
  );
}
