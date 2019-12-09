import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/auth_screen.dart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            builder: (ctx, auth, previousProds) => Products(auth.token,
                auth.userId, previousProds != null ? previousProds.items : []),
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
              builder: (ctx, auth, previous) => Orders(auth.token, auth.userId,
                  previous == null ? [] : previous.orders)),
        ],
        child: Consumer<Auth>(
          builder: (ctx, authi, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Oscari',
              theme: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
              ),
              home: authi.isAuth ? ProductsOverviewScreen() : AuthScreen(),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                ProductsOverviewScreen.name: (ctx) => ProductsOverviewScreen(),
              }),
        ));
  }
}
