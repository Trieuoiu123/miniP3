import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_ocr_expense_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Định dạng các mốc tiền theo quy chuẩn đề bài', () {
      expect(CurrencyFormatter.format(0), '0 đ');
      expect(CurrencyFormatter.format(15000), '15.000 đ');
      expect(CurrencyFormatter.format(250000), '250.000 đ');
      expect(CurrencyFormatter.format(1250000), '1.250.000 đ');
    });

    test('Định dạng các số tiền khác và số lớn', () {
      expect(CurrencyFormatter.format(500), '500 đ');
      expect(CurrencyFormatter.format(10000000), '10.000.000 đ');
      expect(CurrencyFormatter.format(999999999), '999.999.999 đ');
    });

    test('Parse chuỗi thành số nguyên VND hợp lệ', () {
      expect(CurrencyFormatter.parse('15.000 đ'), 15000);
      expect(CurrencyFormatter.parse('250,000 VND'), 250000);
      expect(CurrencyFormatter.parse('1.250.000'), 1250000);
      expect(CurrencyFormatter.parse('  350000  '), 350000);
      expect(CurrencyFormatter.parse('0'), 0);
    });

    test('Parse trả về null khi dữ liệu không hợp lệ hoặc âm', () {
      expect(CurrencyFormatter.parse(null), isNull);
      expect(CurrencyFormatter.parse(''), isNull);
      expect(CurrencyFormatter.parse('abc'), isNull);
      expect(CurrencyFormatter.parse('-50000'), isNull);
    });
  });
}
