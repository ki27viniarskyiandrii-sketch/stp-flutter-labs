import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/order_repository.dart';
import '../models/models.dart';

enum CheckoutStatus { idle, submitting, success, failure }

class CartState extends Equatable {
  const CartState({
    this.items = const {},
    this.status = CheckoutStatus.idle,
    this.orderId,
    this.errorMessage,
  });

  final Map<Product, int> items;
  final CheckoutStatus status;
  final String? orderId;
  final String? errorMessage;

  int get count => items.values.fold(0, (a, b) => a + b);
  int get total =>
      items.entries.fold(0, (sum, e) => sum + e.key.price * e.value);

  CartState copyWith({
    Map<Product, int>? items,
    CheckoutStatus? status,
    String? orderId,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      status: status ?? this.status,
      orderId: orderId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [items, status, orderId, errorMessage];
}

class CartCubit extends Cubit<CartState> {
  CartCubit(this._orders) : super(const CartState());

  final OrderRepository _orders;

  void add(Product product) {
    final items = Map.of(state.items);
    items[product] = (items[product] ?? 0) + 1;
    emit(state.copyWith(items: items, status: CheckoutStatus.idle));
  }

  void remove(Product product) {
    final items = Map.of(state.items);
    final left = (items[product] ?? 0) - 1;
    if (left <= 0) {
      items.remove(product);
    } else {
      items[product] = left;
    }
    emit(state.copyWith(items: items, status: CheckoutStatus.idle));
  }

  Future<void> checkout() async {
    if (state.items.isEmpty) {
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: 'Кошик порожній',
      ));
      return;
    }
    emit(state.copyWith(status: CheckoutStatus.submitting));
    try {
      final id = await _orders.placeOrder(state.items);
      emit(const CartState().copyWith(
        status: CheckoutStatus.success,
        orderId: id,
      ));
    } on OrderException catch (e) {
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: e.message,
      ));
    }
  }
}
