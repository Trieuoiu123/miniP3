import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_ocr_expense_tracker/models/receipt.dart';

void main() {
  group('Receipt Model Tests', () {
    test('Khởi tạo model hợp lệ và toMap / fromMap khớp dữ liệu', () {
      final now = DateTime(2026, 10, 12, 14, 30);
      final receipt = Receipt(
        id: 1,
        merchant: 'Cửa hàng tiện lợi 7-Eleven',
        totalAmount: 125000,
        receiptDate: DateTime(2026, 10, 12),
        rawOcrText: '7-Eleven\nTổng tiền: 125.000 đ',
        imagePath: '/data/user/0/receipts/img_001.jpg',
        createdAt: now,
      );

      final map = receipt.toMap();
      expect(map['id'], 1);
      expect(map['merchant'], 'Cửa hàng tiện lợi 7-Eleven');
      expect(map['total_amount'], 125000);
      expect(map['total_amount'], isA<int>());
      expect(map['receipt_date'], DateTime(2026, 10, 12).toIso8601String());

      final restored = Receipt.fromMap(map);
      expect(restored.id, receipt.id);
      expect(restored.merchant, receipt.merchant);
      expect(restored.totalAmount, receipt.totalAmount);
      expect(restored.totalAmount, isA<int>());
      expect(restored.receiptDate, receipt.receiptDate);
      expect(restored.rawOcrText, receipt.rawOcrText);
      expect(restored.imagePath, receipt.imagePath);
    });

    test('Không cho phép khởi tạo Receipt với tổng tiền âm', () {
      expect(
        () => Receipt(
          merchant: 'Siêu thị Go!',
          totalAmount: -1000,
          receiptDate: DateTime.now(),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('copyWith hoạt động chính xác khi cập nhật từng trường', () {
      final receipt = Receipt(
        id: 2,
        merchant: 'Highlands Coffee',
        totalAmount: 45000,
        receiptDate: DateTime(2026, 10, 1),
      );

      final updated = receipt.copyWith(
        merchant: 'Highlands Coffee Landmark',
        totalAmount: 65000,
      );

      expect(updated.id, 2);
      expect(updated.merchant, 'Highlands Coffee Landmark');
      expect(updated.totalAmount, 65000);
      expect(updated.receiptDate, DateTime(2026, 10, 1));
    });

    test('fromMap xử lý an toàn khi map thiếu các trường optional hoặc kiểu tiền khác int', () {
      final map = {
        'merchant': 'Quán ăn Cô Ba',
        'total_amount': '50000',
        'receipt_date': '2026-10-10',
      };

      final receipt = Receipt.fromMap(map);
      expect(receipt.id, isNull);
      expect(receipt.merchant, 'Quán ăn Cô Ba');
      expect(receipt.totalAmount, 50000);
      expect(receipt.receiptDate.year, 2026);
      expect(receipt.receiptDate.month, 10);
      expect(receipt.receiptDate.day, 10);
      expect(receipt.rawOcrText, isNull);
      expect(receipt.imagePath, isNull);
    });
  });
}
