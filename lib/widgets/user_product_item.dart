import 'package:course_shop_app/providers/products.dart';
import 'package:course_shop_app/screens/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:course_shop_app/providers/product.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final Product product;

  UserProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName, arguments: product);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Theme.of(context).errorColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: Text('Delete Item'),
                    content: Text('Are you sure you want to delete product?'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () async {
                          String message = null;
                          try {
                            await Provider.of<Products>(context, listen: false).removeProduct(product.id);
                          } catch (error) {
                            message = error.toString();
                          } finally {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message == null ? 'Successfully deleted' : message,
                                  textAlign: TextAlign.center,
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: message == null
                                    ? Theme.of(ctx).snackBarTheme.backgroundColor
                                    : Theme.of(ctx).errorColor,
                              ),
                            );
                            Navigator.of(ctx).pop();
                          }
                        },
                      ),
                      // ignore: deprecated_member_use
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
