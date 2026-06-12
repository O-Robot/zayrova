import 'package:flutter/material.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/components/confirmation_modal.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreen();
}

class _CartScreen extends State<CartScreen> {
  bool showCheckoutSummary = false;
  bool showDeleteConfirmation = false;

  void toggleCheckoutSummary(bool value) {
    setState(() {
      showCheckoutSummary = value;
      showDeleteConfirmation = false;
    });
  }

  void toggleDeleteConfirmation(bool value) {
    setState(() {
      showDeleteConfirmation = value;
      showCheckoutSummary = false;
    });
  }

  void resetBottomNav() {
    setState(() {
      showCheckoutSummary = false;
      showDeleteConfirmation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TopNavigation(text: 'My Cart'),
                ),
                const SizedBox(height: 30),

                // TODO: Your cart items list here
              ],
            ),

            // Conditional Delete Confirmation Modal
            if (!showDeleteConfirmation)
              ConfirmationModal(
                type: 'cart',
                itemTitle: 'Nike Air Max 90',
                onCancel: resetBottomNav,
                onConfirm: () {
                  // Perform delete
                  resetBottomNav();
                },
              ),
          ],
        ),
      ),

      // Bottom nav section switches based on flags
      // bottomNavigationBar: AnimatedSwitcher(
      //   duration: const Duration(milliseconds: 250),
      //   child:
      //      null
      // ),
    );
  }
}
