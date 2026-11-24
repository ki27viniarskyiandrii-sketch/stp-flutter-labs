import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../logic/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Кошик')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.status == CheckoutStatus.success) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text('Замовлення оформлено'),
                  Text('Номер: ${state.orderId}'),
                ],
              ),
            );
          }
          final entries = state.items.entries.toList();
          return Column(
            children: [
              Expanded(
                child: entries.isEmpty
                    ? const Center(child: Text('Кошик порожній'))
                    : ListView(
                        children: [
                          for (final e in entries)
                            ListTile(
                              title: Text(e.key.title),
                              subtitle: Text('${e.value} шт. x ${e.key.price} грн'),
                              trailing: IconButton(
                                tooltip: 'Прибрати',
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () =>
                                    context.read<CartCubit>().remove(e.key),
                              ),
                            ),
                        ],
                      ),
              ),
              if (state.status == CheckoutStatus.failure)
                Text(
                  state.errorMessage ?? '',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: Text('Разом: ${state.total} грн')),
                    Semantics(
                      identifier: 'checkout_button',
                      child: FilledButton(
                        onPressed: state.status == CheckoutStatus.submitting
                            ? null
                            : () => context.read<CartCubit>().checkout(),
                        child: const Text('Оформити замовлення'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
