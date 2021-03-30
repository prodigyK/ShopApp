import 'package:course_shop_app/models/http_exception.dart';
import 'package:course_shop_app/providers/cart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Map<String, dynamic> toJson() => {
        'amount': this.amount,
        'products': this.products,
        'dateTime': this.dateTime,
      };
}

class Orders with ChangeNotifier {
  final String _token;
  final String _userId;
  List<OrderItem> _orders = [];

  Orders(this._token, this._userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
      'flutter-update-ff1b1-default-rtdb.firebaseio.com',
      '/orders/$_userId.json',
      {'auth': _token},
    );

    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw HttpException('Problems with fetching data from remote repository');
    }
    final fetchingData = json.decode(response.body) as Map<String, dynamic>;
    if (fetchingData == null) {
      return;
    }
    final List<OrderItem> loadedOrders = [];
    fetchingData.forEach((orderKey, orderValue) {
      final productsList = orderValue['products'] as List<dynamic>;
      final List<CartItem> products = [];
      productsList.forEach((value) {
        products.add(
          CartItem(
            id: value['id'],
            title: value['title'],
            quantity: value['quantity'],
            price: value['price'],
          ),
        );
      });
      var orderItem = OrderItem(
        id: orderKey,
        amount: orderValue['amount'],
        products: products,
        dateTime: DateTime.parse(orderValue['dateTime']),
      );
      loadedOrders.add(orderItem);
//      loadedOrders.insert(0, orderItem);
    });
    _orders = loadedOrders.reversed.toList();
    print('notifyListeners() - fetchAndSetOrders - is called');
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final url = Uri.https(
      'flutter-update-ff1b1-default-rtdb.firebaseio.com',
      '/orders/$_userId.json',
      {'auth': _token},
    );

    final timestamp = DateTime.now();
    final productsJson = json.encode(products.map((e) => e.toJson()).toList());
    final response = await http.post(
      url,
      body: json.encode({
        'amount': double.parse(total.toStringAsFixed(2)),
        'dateTime': timestamp.toIso8601String(),
        'products': products.map((e) => e.toJson()).toList(),
      }),
    );
    if (response.statusCode >= 400) {
      throw HttpException('Something went wrong during adding a new order');
    }

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          products: products,
          amount: total,
          dateTime: timestamp,
        ));
    notifyListeners();
  }
}
