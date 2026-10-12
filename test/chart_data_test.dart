import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_ocr_expense_tracker/features/dashboard/widgets/monthly_expense_chart.dart';
import 'package:receipt_ocr_expense_tracker/models/receipt.dart';

void main() {
  group('ChartDataAggregator Tests', () {
    final refDate = DateTime(2026, 10, 12);

    test('1. Danh sách hóa đơn rỗng: tạo 7 điểm dữ liệu toàn số 0', () {
      final points = ChartDataAggregator.aggregateDaily(
        [],
        days: 7,
        referenceDate: refDate,
      );

      expect(points.length, 7);
      for (final p in points) {
        expect(p.amount, 0);
      }
      expect(points.last.label, '12/10');
      expect(points.first.label, '6/10');
    });

    test('2. Tổng hợp chính xác chi tiêu trong các ngày khác nhau', () {
      final receipts = [
        Receipt(
          merchant: 'Circle K',
          totalAmount: 50000,
          receiptDate: DateTime(2026, 10, 12, 10),
        ),
        Receipt(
          merchant: 'GS25',
          totalAmount: 30000,
          receiptDate: DateTime(2026, 10, 12, 15),
        ),
        Receipt(
          merchant: 'Highlands',
          totalAmount: 65000,
          receiptDate: DateTime(2026, 10, 10),
        ),
        // Hóa đơn ngoài phạm vi 7 ngày (ngày 01/10)
        Receipt(
          merchant: 'Siêu thị Coop',
          totalAmount: 500000,
          receiptDate: DateTime(2026, 10, 1),
        ),
      ];

      final points = ChartDataAggregator.aggregateDaily(
        receipts,
        days: 7,
        referenceDate: refDate,
      );

      // Điểm ngày 12/10 phải có tổng là 50000 + 30000 = 80000
      final todayPoint = points.firstWhere((p) => p.label == '12/10');
      expect(todayPoint.amount, 80000);

      // Điểm ngày 10/10 phải có 65000
      final day10Point = points.firstWhere((p) => p.label == '10/10');
      expect(day10Point.amount, 65000);

      // Các ngày không có hóa đơn (ví dụ 11/10) phải là 0
      final day11Point = points.firstWhere((p) => p.label == '11/10');
      expect(day11Point.amount, 0);

      // Hóa đơn ngày 01/10 không được xuất hiện
      expect(points.any((p) => p.amount == 500000), isFalse);
    });

    test('3. Tổng hợp chi tiêu theo tháng (6 tháng gần nhất)', () {
      final receipts = [
        Receipt(
          merchant: 'Tiền nhà tháng 10',
          totalAmount: 4000000,
          receiptDate: DateTime(2026, 10, 5),
        ),
        Receipt(
          merchant: 'Tiền điện tháng 9',
          totalAmount: 600000,
          receiptDate: DateTime(2026, 9, 20),
        ),
      ];

      final points = ChartDataAggregator.aggregateMonthly(
        receipts,
        months: 6,
        referenceDate: refDate,
      );

      expect(points.length, 6);
      final octPoint = points.firstWhere((p) => p.label == 'T10');
      expect(octPoint.amount, 4000000);

      final sepPoint = points.firstWhere((p) => p.label == 'T9');
      expect(sepPoint.amount, 600000);
    });

    test('4. Xử lý khi số ngày yêu cầu là 0 hoặc âm', () {
      final points = ChartDataAggregator.aggregateDaily([], days: 0);
      expect(points, isEmpty);
    });
  });
}
