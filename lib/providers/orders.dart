import 'package:flutter/material.dart';
import 'package:shopping_app/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.amount,
    @required this.dateTime,
    @required this.id,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url = 'https://flutter-update-2b432.firebaseio.com/orders.json';
    final response = await http.get(url);
    final List<OrderItem> loadedProducts = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) return;
    extractedData.forEach((orderId, orderData) {
      loadedProducts.add(
        OrderItem(
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          id: orderId,
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: double.parse(item['price'].toString()),
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedProducts.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://flutter-update-2b432.firebaseio.com/orders.json';
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.quantity,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
          amount: total,
          dateTime: timeStamp,
          id: json.decode(response.body)['name'],
          products: cartProducts),
    );
    notifyListeners();
  }
}
