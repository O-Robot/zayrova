import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/orders/order_components.dart';
import 'package:zayrova/presentation/pages/orders/order_review_store.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class OrderRatingScreen extends StatefulWidget {
  const OrderRatingScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<OrderRatingScreen> createState() => _OrderRatingScreenState();
}

class _OrderRatingScreenState extends State<OrderRatingScreen> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingReview() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      return;
    }

    final review = await OrderReviewStore.getReview(orderId);
    if (!mounted || review == null) {
      return;
    }

    setState(() {
      _rating = review.rating;
      _reviewController.text = review.review;
    });
  }

  Future<void> _submitReview() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      setState(() {
        _validationMessage = 'This order cannot be reviewed.';
      });
      return;
    }

    if (_rating == 0) {
      setState(() {
        _validationMessage = 'Select a star rating before submitting.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationMessage = null;
    });

    await OrderReviewStore.saveReview(
      StoredOrderReview(
        orderId: orderId,
        rating: _rating,
        review: _reviewController.text.trim(),
        submittedAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review saved.')),
    );
    ZayRouter.goto(ZayRoutes.orders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const OrderHeader(title: 'Rate Order'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IntroCard(orderId: widget.orderId),
                    const SizedBox(height: 26),
                    _RatingPicker(
                      rating: _rating,
                      onChanged: (rating) {
                        setState(() {
                          _rating = rating;
                          _validationMessage = null;
                        });
                      },
                    ),
                    if (_validationMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _validationMessage!,
                        style:
                            ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                          color: const Color(0xFFD32F2F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    _ReviewInput(controller: _reviewController),
                    const SizedBox(height: 30),
                    ZayButton.primary(
                      action: _submitReview,
                      text: 'Submit Review',
                      isLoading: _isSubmitting,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 14),
                    ZayButton.outline(
                      action: () => ZayRouter.goto(ZayRoutes.orders),
                      text: 'Back to Orders',
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orderId == null || orderId!.isEmpty
                ? 'Order Review'
                : 'Order #$orderId',
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tell us how the order went. Your feedback helps improve the shopping experience.',
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: ZayColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingPicker extends StatelessWidget {
  const _RatingPicker({
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How was your order?',
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final value = index + 1;
            return IconButton(
              onPressed: () => onChanged(value),
              icon: Icon(
                value <= rating ? Icons.star : Icons.star_border,
                color: ZayColors.primary,
                size: 38,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ReviewInput extends StatelessWidget {
  const _ReviewInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Write a Review',
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 7,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Share your experience',
            hintStyle: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: ZayColors.textSecondary,
            ),
            filled: true,
            fillColor: const Color(0xFFFBFBFD),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEDEEF4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ZayColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
