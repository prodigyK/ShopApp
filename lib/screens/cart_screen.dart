import 'package:course_shop_app/providers/orders.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart-screen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final listItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.headline6.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  // ignore: deprecated_member_use
                  FlatButton(
                    child: _isLoading ? CircularProgressIndicator() : Text(
                      'ORDER NOW',
                      style: TextStyle(
                          color:
                              cart.totalAmount <= 0 ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: cart.totalAmount <= 0
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              await Provider.of<Orders>(context, listen: false).addOrder(listItems, cart.totalAmount);
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.toString(), textAlign: TextAlign.center),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } finally {
                              cart.clearCart();
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) {
                  final double sum = listItems[i].price * listItems[i].quantity;
                  return CartItem(
                    productId: cart.items.keys.toList()[i],
                    id: listItems[i].id,
                    title: listItems[i].title,
                    quantity: listItems[i].quantity,
                    price: sum,
                  );
                }),
          ),
        ],
      ),
    );
  }
}
