import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  bool _isExpanded = false;
  int _selectedVariantIndex = 0;
  int selectedIndex = 0;

  final List<Map<String, dynamic>> variants = [
    {"label": "XL", "inStock": true},
    {"label": "L", "inStock": false},
    {"label": "M", "inStock": true},
    {"label": "S", "inStock": true},
  ];

  final List<Map<String, dynamic>> colorOptions = [
    {'name': 'Nude', 'color': const Color(0xFFD8AE9D)},
    {'name': 'Brown', 'color': const Color(0xFF7C6759)},
    {'name': 'Peach', 'color': const Color(0xFFE09B6D)},
    {'name': 'Tan', 'color': const Color(0xFFA66B45)},
    {'name': 'Green', 'color': const Color(0xFF2C6B52)},
    {'name': 'Black', 'color': const Color(0xFF1E1E1E)},
  ];

  final List<String> images = [
    'https://images.pexels.com/photos/7974/pexels-photo.jpg',
    'https://images.pexels.com/photos/18105/pexels-photo.jpg',
    'https://images.pexels.com/photos/18107/pexels-photo.jpg',
  ];

  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      bottomNavigationBar: _AddToCart(),
      body: Stack(
        children: [
          // Main image at the top
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.network(
                  images[selectedImageIndex],
                  fit: BoxFit.cover,
                  height: 400,
                  errorBuilder:
                      (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image)),
                  loadingBuilder:
                      (context, child, progress) =>
                          progress == null
                              ? child
                              : const Center(
                                child: CircularProgressIndicator(),
                              ),
                ),
              ],
            ),
          ),

          // Top bar with back and favorite buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => ZayRouter.goBack(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ZayColors.white,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: ZayColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    'Product Details',
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.white,
                    ),
                  ),
                  // Favorite button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ZayColors.white,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: ZayColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Overlay bottom section — make sure it overlaps the image
          Positioned(
            top: 350, // image is 400; this gives a 80px overlay
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: const BoxDecoration(
                color: ZayColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail images
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImageIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      selectedImageIndex == index
                                          ? ZayColors.secondary
                                          : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  images[index],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "HP Elitebook 840 Intel Core i7",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text("4.5"),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      "Product Details",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),

                    // priduct description
                    AnimatedCrossFade(
                      crossFadeState:
                          _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                      firstChild: const Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: const Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: Text(
                        _isExpanded ? "Read less" : "Read more",
                        style: const TextStyle(
                          color: ZayColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Variant selector
                    Text(
                      "Variation",
                      style: ZayTheme.lightTheme.textTheme.displayLarge
                          ?.copyWith(color: ZayColors.textPrimary),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: List.generate(variants.length, (index) {
                        final variant = variants[index];
                        final isSelected = index == _selectedVariantIndex;

                        return GestureDetector(
                          onTap:
                              variant["inStock"]
                                  ? () => setState(
                                    () => _selectedVariantIndex = index,
                                  )
                                  : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? ZayColors.primary
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    variant["inStock"]
                                        ? Colors.transparent
                                        : Colors.red,
                              ),
                            ),
                            child: Text(
                              variant["label"] +
                                  (variant["inStock"] ? "" : " (Out of Stock)"),
                              style: TextStyle(
                                color:
                                    variant["inStock"]
                                        ? (isSelected
                                            ? Colors.white
                                            : Colors.black)
                                        : Colors.red,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    // colour slection
                    RichText(
                      text: TextSpan(
                        text: 'Select Colour: ',
                        style: ZayTheme.lightTheme.textTheme.displayLarge
                            ?.copyWith(color: ZayColors.textPrimary),
                        children: [
                          TextSpan(
                            text: colorOptions[selectedIndex]['name'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(colorOptions.length, (index) {
                        final color = colorOptions[index]['color'];
                        final isSelected = index == selectedIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: color,
                              child:
                                  isSelected
                                      ? const CircleAvatar(
                                        radius: 6,
                                        backgroundColor: Colors.white,
                                      )
                                      : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCart extends StatelessWidget {
  // final String value;
  // const _AddToCart(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 10),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Price",
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                ),
              ),
              Text(
                "\$83.97",
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 200,
            child: ZayButton.icon(action: () {}, text: 'Add to Cart'),
          ),
        ],
      ),
    );
  }
}
