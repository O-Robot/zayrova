import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/search/catalog_filter.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/providers/feature/catalog_controller.dart';

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key, this.initialFilters});

  final CatalogFilterValues? initialFilters;

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  static const List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated',
    'Newest',
  ];

  static const List<double> _ratings = [4.5, 4.0, 3.5, 3.0];

  String _selectedCategory = 'All';
  String _selectedSort = _sortOptions.first;
  RangeValues _priceRange = const RangeValues(0, 3000);
  double? _minimumRating;
  bool _inStockOnly = false;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters ?? const CatalogFilterValues();
    _selectedCategory = filters.categoryName ?? 'All';
    _selectedSort = filters.sort.label;
    _priceRange = RangeValues(
      filters.minimumPrice.clamp(0, 3000).toDouble(),
      filters.maximumPrice.clamp(0, 3000).toDouble(),
    );
    _minimumRating = filters.minimumRating;
    _inStockOnly = filters.inStockOnly;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalogState = ref.read(catalogControllerProvider);
      if (!catalogState.hasLoadedCategories && !catalogState.isLoading) {
        ref.read(catalogControllerProvider.notifier).loadCategories();
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedSort = _sortOptions.first;
      _priceRange = const RangeValues(0, 3000);
      _minimumRating = null;
      _inStockOnly = false;
    });
  }

  void _applyFilters() {
    Navigator.of(context).pop(
      CatalogFilterValues(
        categoryName: _selectedCategory == 'All' ? null : _selectedCategory,
        minimumRating: _minimumRating,
        sort: CatalogFilterSort.fromLabel(_selectedSort),
        inStockOnly: _inStockOnly,
        minimumPrice: _priceRange.start,
        maximumPrice: _priceRange.end,
      ).toMap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogControllerProvider);
    final categoryOptions = [
      'All',
      ...catalogState.categories.map((category) => category.name),
    ];
    final selectedCategory = categoryOptions.contains(_selectedCategory)
        ? _selectedCategory
        : 'All';

    return Scaffold(
      appBar: null,
      backgroundColor: ZayColors.white,
      bottomNavigationBar: _FilterActions(
        onReset: _resetFilters,
        onApply: _applyFilters,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TopNavigation(text: 'Filter'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterSection(
                      title: 'Category',
                      child: _FilterChoiceWrap(
                        options: categoryOptions,
                        selectedOption: selectedCategory,
                        onSelected: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      ),
                    ),
                    _FilterSection(
                      title: 'Price Range',
                      child: _PriceRangeSelector(
                        values: _priceRange,
                        onChanged: (values) {
                          setState(() => _priceRange = values);
                        },
                      ),
                    ),
                    _FilterSection(
                      title: 'Rating',
                      child: _RatingSelector(
                        ratings: _ratings,
                        selectedRating: _minimumRating,
                        onSelected: (rating) {
                          setState(() {
                            _minimumRating =
                                _minimumRating == rating ? null : rating;
                          });
                        },
                      ),
                    ),
                    _FilterSection(
                      title: 'Sort By',
                      child: _FilterChoiceWrap(
                        options: _sortOptions,
                        selectedOption: _selectedSort,
                        onSelected: (value) {
                          setState(() => _selectedSort = value);
                        },
                      ),
                    ),
                    _FilterSection(
                      title: 'Availability',
                      child: _AvailabilitySwitch(
                        value: _inStockOnly,
                        onChanged: (value) {
                          setState(() => _inStockOnly = value);
                        },
                      ),
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

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FilterChoiceWrap extends StatelessWidget {
  const _FilterChoiceWrap({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selectedOption;

        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? ZayColors.primary : ZayColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? ZayColors.primary : ZayColors.inputBorder,
              ),
            ),
            child: Text(
              option,
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: isSelected ? ZayColors.white : ZayColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriceRangeSelector extends StatelessWidget {
  const _PriceRangeSelector({
    required this.values,
    required this.onChanged,
  });

  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _PricePill(label: '\$${values.start.round()}'),
            const Spacer(),
            _PricePill(label: '\$${values.end.round()}'),
          ],
        ),
        RangeSlider(
          min: 0,
          max: 3000,
          divisions: 30,
          values: values,
          activeColor: ZayColors.primary,
          inactiveColor: ZayColors.inputBorder,
          labels: RangeLabels(
            '\$${values.start.round()}',
            '\$${values.end.round()}',
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ZayColors.cancel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
          color: ZayColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({
    required this.ratings,
    required this.selectedRating,
    required this.onSelected,
  });

  final List<double> ratings;
  final double? selectedRating;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ratings.map((rating) {
        final isSelected = rating == selectedRating;

        return GestureDetector(
          onTap: () => onSelected(rating),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? ZayColors.primary : ZayColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? ZayColors.primary : ZayColors.inputBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: isSelected ? ZayColors.white : ZayColors.secondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${rating.toStringAsFixed(1)}+',
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color:
                        isSelected ? ZayColors.white : ZayColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AvailabilitySwitch extends StatelessWidget {
  const _AvailabilitySwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ZayColors.white,
        border: Border.all(color: ZayColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Show in-stock products only',
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: ZayColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterActions extends StatelessWidget {
  const _FilterActions({
    required this.onReset,
    required this.onApply,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: ZayColors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                text: 'Reset',
                isPrimary: false,
                onTap: onReset,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                text: 'Apply Filter',
                isPrimary: true,
                onTap: onApply,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.isPrimary,
    required this.onTap,
  });

  final String text;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? ZayColors.primary : ZayColors.cancel,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: isPrimary ? ZayColors.white : ZayColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
