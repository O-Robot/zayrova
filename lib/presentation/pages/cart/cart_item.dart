// cart_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CartItem extends StatelessWidget {
  final VoidCallback onDeleteRequest;

  const CartItem({super.key, required this.onDeleteRequest});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25, // slide all the way before showing
        children: [
          SlidableAction(
            onPressed: (context) {
              onDeleteRequest();
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        child: ListTile(
          title: Text('Product Name'),
          subtitle: Text('Qty: 1'),
          trailing: Text('₦5,000'),
        ),
      ),
    );
  }
}
