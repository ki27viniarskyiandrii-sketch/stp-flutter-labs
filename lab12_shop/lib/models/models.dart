import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.email, required this.name});

  final String email;
  final String name;

  @override
  List<Object?> get props => [email, name];
}

class Product extends Equatable {
  const Product({required this.id, required this.title, required this.price});

  final int id;
  final String title;
  final int price; // у гривнях

  @override
  List<Object?> get props => [id, title, price];
}

/// Товари для каталогу.
const demoProducts = [
  Product(id: 1, title: 'Зошит А4', price: 45),
  Product(id: 2, title: 'Ручка гелева', price: 20),
  Product(id: 3, title: 'Флешка 32 ГБ', price: 250),
  Product(id: 4, title: 'Навушники', price: 600),
];
