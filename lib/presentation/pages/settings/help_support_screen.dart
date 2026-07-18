import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final searchController = TextEditingController();
  int expandedIndex = 2;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faqs = [
      _FaqItem(
        title: 'How do I track my order?',
        body:
            'Open My Order, choose an active order, then view the tracking timeline.',
      ),
      _FaqItem(
        title: 'How do I change my delivery address?',
        body:
            'Go to Address from checkout or profile, then select or add a new address.',
      ),
      _FaqItem(
        title: 'How do payments work?',
        body:
            'Choose a saved payment method during checkout, review your order, then confirm from the payment screen.',
      ),
      _FaqItem(
        title: 'How do I update my profile?',
        body:
            'Open Settings, choose Edit Profile, then update the available account fields.',
      ),
      _FaqItem(
        title: 'How do I contact support?',
        body:
            'Use the Messages area from your profile to view support conversations and updates.',
      ),
    ];

    return ProfilePageShell(
      title: 'Help and Support',
      showMenu: false,
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search help',
            prefixIcon: const Icon(
              Icons.search,
              color: ZayColors.textSecondary,
            ),
            filled: true,
            fillColor: const Color(0xFFFBFBFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(faqs.length, (index) {
          final faq = faqs[index];
          final isExpanded = expandedIndex == index;

          return _FaqTile(
            item: faq,
            isExpanded: isExpanded,
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? -1 : index;
              });
            },
          );
        }),
      ],
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.title, required this.body});

  final String title;
  final String body;
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  final _FaqItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: ZayColors.cancel)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: ZayColors.textPrimary,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 14),
              Text(
                item.body,
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                  height: 1.65,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
