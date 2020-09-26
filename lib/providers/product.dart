import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.description,
    @required this.title,
    @required this.price,
    this.isFavorite = false,
    @required this.imageUrl,
  });

  void toggleFavorites() async {
    final oldFavorites = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://flutter-update-2b432.firebaseio.com/products/$id.json';
    try {
      final response = await http.patch(url,
          body: json.encode({
            'isFavorite': isFavorite,
          }));
      if (response.statusCode >= 400) {
        isFavorite = oldFavorites;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldFavorites;
      notifyListeners();
    }
  }
}
