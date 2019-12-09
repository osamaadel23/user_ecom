import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/providers/product.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String token;
  final String userId;
  Orders(this.token, this.userId, this._orders);
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var url =
        'https://flutter-updated.firebaseio.com/usersOrders/$userId.json?auth=$token';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'total': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((pi) => {
                    'id': pi.id,
                    'price': pi.price,
                    'quantity': pi.quantity,
                    'title': pi.title,
                  })
              .toList()
        }));

    //* Admin orders
    url =
        'https://flutter-updated.firebaseio.com/totalOrders.json?auth=$token';
   
     await http.post(url,
        body: json.encode({
          'userId' : userId,
          'total': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((pi) => {
                    'id': pi.id,
                    'price': pi.price,
                    'quantity': pi.quantity,
                    'title': pi.title,
                  })
              .toList()
        }));
    //* insert orders to the orders list
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
      ),
    );
    notifyListeners();

    url = 'https://flutter-updated.firebaseio.com/notification.json';
    final getValue = await http.get(url);
    final extractValue = json.decode(getValue.body);
    await http.put(url, body: json.encode(extractValue + 1));
    // List<int> list;
    // cartProducts.map((prod) async {
    //   url = 'https://flutter-updated.firebaseio.com/products/${prod.id}.json';
    //   final resp = await http.get(url);
    //   list.add(json.decode(resp.body)['quantity']);
    //  print(json.decode(resp.body)['quantity']);
    // });
    // int i = 0;
    // cartProducts.map((prod) async {
    //   url = 'https://flutter-updated.firebaseio.com/products/${prod.id}.json';
    //   await http.patch(url,
    //       body: json.encode({'quantity': list[i] - prod.quantity}));
    //// print(list[i] - prod.quantity);
    //   i++;
    // });
  }

  Future<void> fetchAndSet() async {
    final url =
        'https://flutter-updated.firebaseio.com/usersOrders/$userId.json?auth=$token';
    final resp = await http.get(url);
    List<OrderItem> loadedOrders = [];
    final son = json.decode(resp.body) as Map<String, dynamic>;
    if (son == null) {
      return;
    }
    son.forEach((id, product) {
      loadedOrders.add(OrderItem(
          id: id,
          amount: product['total'],
          dateTime: DateTime.parse(product['dateTime']),
          products: (product['products'] as List).map((item) {
            return CartItem(
              id: item['id'],
              title: item['title'],
              quantity: item['quantity'],
              price: item['price'],
            );
          }).toList()));
    });
    _orders = loadedOrders;
    notifyListeners();
  }
}
