import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_ocr_expense_tracker/core/utils/date_parser.dart';

void main() {
  group('DateParser Tests', () {
    test('Định dạng DateTime sang dd/MM/yyyy', () {
      final date = DateTime(2026, 10, 12);
      expect(DateParser.format(date), '12/10/2026');

      final date2 = DateTime(2026, 5, 4);
      expect(DateParser.format(date2), '04/05/2026');
    });

    test('Parse thành công các định dạng phổ biến', () {
      final d1 = DateParser.parse('12/10/2026');
      expect(d1, isNotNull);
      expect(d1!.year, 2026);
      expect(d1.month, 10);
      expect(d1.day, 12);

      final d2 = DateParser.parse('12-10-2026');
      expect(d2, isNotNull);
      expect(d2!.year, 2026);
      expect(d2.month, 10);
      expect(d2.day, 12);

      final d3 = DateParser.parse('2026-10-12');
      expect(d3, isNotNull);
      expect(d3!.year, 2026);
      expect(d3.month, 10);
      expect(d3.day, 12);
    });

    test('Từ chối ngày không tồn tại và không để tự cuộn ngày', () {
      // 31/02/2026 không tồn tại
      expect(DateParser.parse('31/02/2026'), isNull);
      // 29/02/2025 không phải năm nhuận
      expect(DateParser.parse('29/02/2025'), isNull);
      // 29/02/2024 là năm nhuận -> hợp lệ
      expect(DateParser.parse('29/02/2024'), isNotNull);
      // Tháng 13
      expect(DateParser.parse('12/13/2026'), isNull);
      // Ngày 32
      expect(DateParser.parse('32/05/2026'), isNull);
    });

    test('Trả về null khi chuỗi rỗng hoặc không có ngày', () {
      expect(DateParser.parse(null), isNull);
      expect(DateParser.parse(''), isNull);
      expect(DateParser.parse('Hóa đơn bán lẻ'), isNull);
      expect(DateParser.parse('123456'), isNull);
    });
  });
}
