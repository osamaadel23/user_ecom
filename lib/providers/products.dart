import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './product.dart';
import '../models/exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  final String _token;
  Products(this._token, this.userId, this._items);
  final String userId;
  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-updated.firebaseio.com/products.json?auth=$_token';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'quantity' : product.quantity,
          'location':product.location,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }

    // }).catchError((error) {
    //   print(error);
    //   throw (error);
    // });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-updated.firebaseio.com/products/$id.json?auth=$_token';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
            'quantity' : newProduct.quantity,
            'category' : newProduct.category,
            'location' : newProduct.location,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> fetchData() async {
    try {
      var url =
          'https://flutter-updated.firebaseio.com/products.json?auth=$_token';
      final response = await http.get(url);
      final extractedData =
          await json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://flutter-updated.firebaseio.com/userFavorites/$userId.json?auth=$_token';
      final statusData = await http.get(url);
      final status = json.decode(statusData.body);  
      final List<Product> prods = [];
      extractedData.forEach((id, map) {
        prods.add(
          Product(
            id: id,
            price: map['price'],
            description: map['description'],
            imageUrl: map['imageUrl'],
            title: map['title'],
            category: map['category'],
            quantity: map['quantity'],
            location: map['location'],
            isFavorite: status == null? false : status[id] ?? false,
          ),
        );
      });
      _items = prods;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-updated.firebaseio.com/products/$id.json?auth=$_token';
    final exsistingProductIndex = _items.indexWhere((item) => item.id == id);
    var exsistingProduct = _items[exsistingProductIndex];
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(exsistingProductIndex, exsistingProduct);
      notifyListeners();
      throw HttpException('Could Not delete products');
    }
    exsistingProduct = null;
  }
}
