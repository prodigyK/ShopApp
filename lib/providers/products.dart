import 'dart:convert';
import 'package:course_shop_app/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  final String _token;
  final String _userId;

  Products(this._token, this._userId, this._items);

  List<Product> _items = [
//    Product(
//      id: 'p1',
//      title: 'Red Shirt',
//      description: 'A red shirt - it is pretty red!',
//      price: 29.99,
//      imageUrl: 'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//    ),
//    Product(
//      id: 'p2',
//      title: 'Trousers',
//      description: 'A nice pair of trousers.',
//      price: 59.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//    ),
//    Product(
//      id: 'p3',
//      title: 'Yellow Scarf',
//      description: 'Warm and cozy - exactly what you need for the winter.',
//      price: 19.99,
//      imageUrl: 'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//    ),
//    Product(
//      id: 'p4',
//      title: 'A Pan',
//      description: 'Prepare any meal you want.',
//      price: 49.99,
//      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//    ),
  ];

  var _showFavoritesOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite == true).toList();
  }

  void setFavorites(bool value) {
    _showFavoritesOnly = value;
    notifyListeners();
  }

  Product getById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool userFilter = false]) async {
    // Get Products
    // ***************************
    Map<String, String> params = userFilter
        ? {
            'orderBy': '"creatorId"',
            'equalTo': '"$_userId"',
            'auth': _token,
          }
        : {
            'auth': _token,
          };
    var url = Uri.https(
      'flutter-update-ff1b1-default-rtdb.firebaseio.com',
      '/products.json',
      params,
    );
    var response = await http.get(url);
    if (response.statusCode >= 400) {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw HttpException('Something went wrong during fetching data form remote storage');
    }
    final fetchingData = json.decode(response.body) as Map<String, dynamic>;

    // Get Favorites
    // **********************
    url = Uri.https(
      'flutter-update-ff1b1-default-rtdb.firebaseio.com',
      '/userFavorites/$_userId.json',
      {'auth': _token},
    );
    response = await http.get(url);
    if (response.statusCode >= 400) {
      throw HttpException('Something went wrong during fetching data form remote storage');
    }
    final fetchingFavoriteData = json.decode(response.body) as Map<String, dynamic>;

    // Set Data
    // ************************
    final List<Product> loadedProducts = [];
    fetchingData.forEach((prodId, prodData) {
      loadedProducts.add(
        Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: fetchingFavoriteData == null ? false : fetchingFavoriteData[prodId] ?? false,
        ),
      );
    });
    _items = loadedProducts;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final id = product.id;

    String newId;
    try {
      if (id == null) {
        final url = Uri.https(
          'flutter-update-ff1b1-default-rtdb.firebaseio.com',
          '/products.json',
          {'auth': _token},
        );
        final response = await http.post(
          url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
            'creatorId': _userId,
          }),
        );
        if (response.statusCode >= 400) {
          throw HttpException('POST: Something went wrong during adding new product');
        }
        newId = json.decode(response.body)['name'];
      } else {
        final url = Uri.https(
          'flutter-update-ff1b1-default-rtdb.firebaseio.com',
          '/products/$id.json',
          {'auth': _token},
        );
        final response = await http.patch(
          url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }),
        );
        if (response.statusCode >= 400) {
          throw HttpException('PATCH: Something went wrong during adding new product');
        }
        newId = json.decode(response.body)['name'];
      }

      final index = _items.indexWhere((prod) => prod.id == id);
      if (id != null) {
        _items.removeAt(index);
      }

      final newProduct = Product(
        id: id != null ? id : newId,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      );
      if (id == null) {
        _items.add(product);
      } else {
        _items.insert(index, newProduct);
      }
    } catch (error) {
      throw (error);
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeProduct(String id) async {
    final url = Uri.https(
      'flutter-update-ff1b1-default-rtdb.firebaseio.com',
      '/products/$id.json',
      {'auth': _token},
    );

    final index = _items.indexWhere((prod) => prod.id == id);
    final product = _items[index];
    _items.removeAt(index);
    notifyListeners();

    final response = await http.delete(url);
    print(response.statusCode);
    if (response.statusCode >= 400) {
      _items.insert(index, product);
      notifyListeners();
      throw HttpException('Something went wrong during deleting product');
    }
  }

  Future<void> toggleFavorite(Product product) async {
    final id = product.id;
    final url = Uri.https(
      'flutter-update-ff1b1-default-rtdb.firebaseio.com',
      '/userFavorites/$_userId/$id.json',
      {'auth': _token},
    );

    final response = await http.put(
      url,
      body: json.encode(!product.isFavorite),
    );
    if (response.statusCode >= 400) {
      throw HttpException('Error: Something went wrong');
    }
    product.toggleFavoriteStatus();
    notifyListeners();
  }
}
