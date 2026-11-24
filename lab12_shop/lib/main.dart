import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'data/auth_repository.dart';
import 'data/order_repository.dart';
import 'logic/cart_cubit.dart';
import 'logic/login_cubit.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(ShopApp(
    authRepository: DemoAuthRepository(),
    orderRepository: DemoOrderRepository(),
  ));
}

class ShopApp extends StatelessWidget {
  const ShopApp({
    super.key,
    required this.authRepository,
    required this.orderRepository,
  });

  final AuthRepository authRepository;
  final OrderRepository orderRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginCubit(authRepository)),
        BlocProvider(create: (_) => CartCubit(orderRepository)),
      ],
      child: MaterialApp(
        title: 'lab12_shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const LoginScreen(),
      ),
    );
  }
}
