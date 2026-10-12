import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_parser.dart';
import '../../../models/receipt.dart';

class ChartDataPoint {
  final String label;
  final int amount;
  final DateTime date;

  ChartDataPoint({
    required this.label,
    required this.amount,
    required this.date,
  });

  @override
  String toString() => 'ChartDataPoint($label: $amount đ)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataPoint &&
          other.label == label &&
          other.amount == amount &&
          other.date == date;

  @override
  int get hashCode => Object.hash(label, amount, date);
}

class ChartDataAggregator {
  /// Tổng hợp chi tiêu cho N ngày gần nhất (mặc định 7 ngày)
  static List<ChartDataPoint> aggregateDaily(
    List<Receipt> receipts, {
    int days = 7,
    DateTime? referenceDate,
  }) {
    if (days <= 0) return [];
    final ref = referenceDate ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);

    // Khởi tạo map cho N ngày
    final Map<String, int> dayTotals = {};
    final List<DateTime> dateList = [];

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = DateParser.formatIsoDate(date);
      dayTotals[key] = 0;
      dateList.add(date);
    }

    // Cộng dồn hóa đơn thuộc các ngày đó
    for (final r in receipts) {
      final rDateKey = DateParser.formatIsoDate(r.receiptDate);
      if (dayTotals.containsKey(rDateKey)) {
        dayTotals[rDateKey] = (dayTotals[rDateKey] ?? 0) + r.totalAmount;
      }
    }

    return dateList.map((d) {
      final key = DateParser.formatIsoDate(d);
      final label = '${d.day}/${d.month}';
      return ChartDataPoint(
        label: label,
        amount: dayTotals[key] ?? 0,
        date: d,
      );
    }).toList();
  }

  /// Tổng hợp chi tiêu cho N tháng gần nhất (mặc định 6 tháng)
  static List<ChartDataPoint> aggregateMonthly(
    List<Receipt> receipts, {
    int months = 6,
    DateTime? referenceDate,
  }) {
    if (months <= 0) return [];
    final ref = referenceDate ?? DateTime.now();

    final List<ChartDataPoint> result = [];
    for (int i = months - 1; i >= 0; i--) {
      int y = ref.year;
      int m = ref.month - i;
      while (m <= 0) {
        m += 12;
        y -= 1;
      }

      int monthTotal = 0;
      for (final r in receipts) {
        if (r.receiptDate.year == y && r.receiptDate.month == m) {
          monthTotal += r.totalAmount;
        }
      }

      result.add(
        ChartDataPoint(
          label: 'T$m',
          amount: monthTotal,
          date: DateTime(y, m, 1),
        ),
      );
    }

    return result;
  }
}

class MonthlyExpenseChart extends StatelessWidget {
  final List<ChartDataPoint> dataPoints;
  final String title;

  const MonthlyExpenseChart({
    super.key,
    required this.dataPoints,
    this.title = 'Chi tiêu 7 ngày gần nhất',
  });

  @override
  Widget build(BuildContext context) {
    final totalInPeriod = dataPoints.fold<int>(0, (sum, p) => sum + p.amount);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tổng: ${CurrencyFormatter.format(totalInPeriod)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarChartPainter(dataPoints: dataPoints),
            ),
          ),
          const SizedBox(height: 14),
          // Bảng tóm tắt văn bản dưới biểu đồ
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: dataPoints.map((point) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: point.amount > 0 ? AppTheme.primaryColor : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${point.label}: ${CurrencyFormatter.formatCompact(point.amount)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChartDataPoint> dataPoints;

  _BarChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final maxAmount = dataPoints.map((e) => e.amount).reduce(max);
    // Tránh chia cho 0 khi tất cả đều 0
    final effectiveMax = maxAmount == 0 ? 100000 : maxAmount;

    final axisPaint = Paint()
      ..color = AppTheme.dividerColor
      ..strokeWidth = 1.0;

    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1.0;

    const bottomPadding = 26.0;
    const topPadding = 18.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final chartWidth = size.width;

    // Vẽ đường cơ sở đáy (baseline)
    final baselineY = size.height - bottomPadding;
    canvas.drawLine(Offset(0, baselineY), Offset(chartWidth, baselineY), axisPaint);

    // Vẽ 2 đường lưới ngang phụ
    final midY1 = baselineY - (chartHeight * 0.5);
    final midY2 = baselineY - chartHeight;
    canvas.drawLine(Offset(0, midY1), Offset(chartWidth, midY1), gridPaint);
    canvas.drawLine(Offset(0, midY2), Offset(chartWidth, midY2), gridPaint);

    final n = dataPoints.length;
    final slotWidth = chartWidth / n;
    final barWidth = (slotWidth * 0.5).clamp(12.0, 32.0);

    for (int i = 0; i < n; i++) {
      final point = dataPoints[i];
      final centerX = (i * slotWidth) + (slotWidth / 2);

      // Chiều cao cột tương ứng
      final ratio = (point.amount / effectiveMax).clamp(0.0, 1.0);
      final barHeight = ratio * chartHeight;
      final barTop = baselineY - barHeight;

      final barRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(
          centerX - (barWidth / 2),
          barTop,
          centerX + (barWidth / 2),
          baselineY,
        ),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );

      // Tô màu cột: gradient nếu > 0, xám nhạt nếu = 0
      final barPaint = Paint();
      if (point.amount > 0) {
        barPaint.shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor, Color(0xFF10B981)],
        ).createShader(barRect.outerRect);
      } else {
        barPaint.color = Colors.grey.shade200;
        // Vẽ vạch nhỏ tối thiểu 3px để nhận biết cột rỗng
        final zeroRect = Rect.fromLTRB(
          centerX - (barWidth / 2),
          baselineY - 3,
          centerX + (barWidth / 2),
          baselineY,
        );
        canvas.drawRect(zeroRect, barPaint);
      }

      if (point.amount > 0) {
        canvas.drawRRect(barRect, barPaint);

        // Vẽ giá trị trên đỉnh cột nếu đủ chỗ
        final valTextSpan = TextSpan(
          text: CurrencyFormatter.formatCompact(point.amount),
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        );
        final valPainter = TextPainter(
          text: valTextSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        valPainter.paint(
          canvas,
          Offset(centerX - (valPainter.width / 2), barTop - valPainter.height - 2),
        );
      }

      // Vẽ nhãn ngày dưới trục
      final labelTextSpan = TextSpan(
        text: point.label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      final labelPainter = TextPainter(
        text: labelTextSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(centerX - (labelPainter.width / 2), baselineY + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    if (dataPoints.length != oldDelegate.dataPoints.length) return true;
    for (int i = 0; i < dataPoints.length; i++) {
      if (dataPoints[i] != oldDelegate.dataPoints[i]) return true;
    }
    return false;
  }
}
