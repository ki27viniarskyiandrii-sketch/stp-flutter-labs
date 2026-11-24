import '../models/models.dart';

class OrderException implements Exception {
  const OrderException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class OrderRepository {
  /// Повертає номер замовлення.
  Future<String> placeOrder(Map<Product, int> items);
}

class DemoOrderRepository implements OrderRepository {
  int _counter = 1000;

  @override
  Future<String> placeOrder(Map<Product, int> items) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _counter++;
    return 'ORD-$_counter';
  }
}
