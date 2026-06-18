import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class ConfirmationModal extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String type;
  final String? message;
  final String? itemTitle;

  const ConfirmationModal({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.type = 'default',
    this.message,
    this.itemTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onCancel,
          child: Container(
            color: const Color(0x80000000),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: ZayColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(66, 173, 171, 171),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Modal Title
                const Text(
                  'Are you sure?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 12),

                // Modal Content Based on Type
                if (type == 'cart') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ZayColors.textSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text('Product Name'),
                        subtitle: Text('Qty: 1'),
                        trailing: Text('₦5,000'),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    message ?? 'Are you sure you want to proceed?',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(child: ZayButton.cancel(action: onCancel)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ZayButton.primary(
                        action: onConfirm,
                        text: 'Remove',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
