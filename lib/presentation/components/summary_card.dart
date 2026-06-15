import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';

class ZaySummaryCard extends StatelessWidget {
  const ZaySummaryCard({
    super.key,
    required this.rows,
    this.title,
    this.footer,
    this.backgroundColor = ZayColors.cancel,
  });

  final String? title;
  final List<ZaySummaryRowData> rows;
  final Widget? footer;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final title = this.title;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ZaySummaryRow(data: row),
            );
          }),
          if (footer != null) ...[
            const SizedBox(height: 8),
            footer!,
          ],
        ],
      ),
    );
  }
}

class CheckoutSummaryCard extends ZaySummaryCard {
  const CheckoutSummaryCard({
    super.key,
    required super.rows,
    super.title,
    super.footer,
    super.backgroundColor,
  });
}

class PriceRow extends ZaySummaryRow {
  PriceRow({
    super.key,
    required String label,
    required String value,
    bool isEmphasized = false,
  }) : super(
          data: ZaySummaryRowData(
            label: label,
            value: value,
            isEmphasized: isEmphasized,
          ),
        );
}

class OrderSummaryRow extends ZaySummaryRow {
  OrderSummaryRow({
    super.key,
    required String label,
    required String value,
    bool isEmphasized = false,
  }) : super(
          data: ZaySummaryRowData(
            label: label,
            value: value,
            isEmphasized: isEmphasized,
          ),
        );
}

class ZaySummaryRow extends StatelessWidget {
  const ZaySummaryRow({super.key, required this.data});

  final ZaySummaryRowData data;

  @override
  Widget build(BuildContext context) {
    final style = data.isEmphasized
        ? ZayTheme.lightTheme.textTheme.displayLarge
        : ZayTheme.lightTheme.textTheme.displayMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            data.label,
            style: style?.copyWith(
              color: data.isEmphasized
                  ? ZayColors.textPrimary
                  : ZayColors.textSecondary,
              fontWeight: data.isEmphasized ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          data.value,
          style: style?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: data.isEmphasized ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class ZaySummaryRowData {
  const ZaySummaryRowData({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;
}
