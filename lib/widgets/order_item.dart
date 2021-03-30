import 'dart:math';

import 'package:course_shop_app/providers/orders.dart' as ord;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  const OrderItem({
    Key key,
    @required this.order,
  }) : super(key: key);

  final ord.OrderItem order;

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Container(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('\S${widget.order.amount.toStringAsFixed(2)}'),
                  ),
                ),
              ),
              title: Text(
                '\$${widget.order.amount}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${DateFormat('dd-mm-yyyy hh:mm').format(widget.order.dateTime)}'),
              trailing: IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            if (_isExpanded)
              Container(
                height: widget.order.products.length * 50.0 + 20,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  children: widget.order.products
                      .map(
                        (prod) => Container(
                          height: 50,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
//                            color: Colors.black12,
                          ),
                          child: Row(
                            children: [
                              Text('${prod.quantity}x', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 10),
                              Text(prod.title, style: TextStyle(fontSize: 20)),
                              Spacer(),
                              Text('\$${prod.quantity * prod.price}', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
