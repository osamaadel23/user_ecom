import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
   String category;
   int quantity;
  final String imageUrl;
  bool isFavorite;
  String location;
  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
    this.category = 'Free',
    this.quantity = 0,
    this.location = 'giza', 
  });

  Future<void> toggleFavoriteStatus(String token,String userId) async {
    final url =
        'https://flutter-updated.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    final bool currentState = this.isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final response = await http.put(url, body: json.encode(isFavorite));
    if(response.statusCode >= 400){
      isFavorite = currentState;
      notifyListeners();
      throw HttpException('Something Went Wrong!');
    }
  }

  Future<void> itemOrdered() async{
    quantity = quantity - 1;
    notifyListeners(); 
    final url = 'https://flutter-updated.firebaseio.com/products/$id.json';
    await http.patch(url,body: json.encode({
      'quantity' : quantity,
    }));
  } 
}
