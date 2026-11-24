import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../logic/cart_cubit.dart';
import '../models/models.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartCubit, int>((c) => c.state.count);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
        actions: [
          Semantics(
            identifier: 'cart_button',
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text('Кошик ($count)'),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Вітаю, ${user.name}!'),
          ),
          for (final p in demoProducts)
            ListTile(
              title: Text(p.title),
              subtitle: Text('${p.price} грн'),
              trailing: Semantics(
                identifier: 'add_${p.id}',
                child: IconButton(
                  tooltip: 'Додати ${p.title}',
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () => context.read<CartCubit>().add(p),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
