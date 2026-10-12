import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_ocr_expense_tracker/services/receipt_parser_service.dart';

void main() {
  late ReceiptParserService parser;

  setUp(() {
    parser = ReceiptParserService();
  });

  group('ReceiptParserService Tests', () {
    test('1. Mẫu OCR đầy đủ thông tin: merchant, date, total', () {
      const ocrText = '''
CIRCLE K VIETNAM
Cửa hàng 123 Nguyễn Huệ, Q.1
Ngày: 12/10/2026 14:35:10
1. Sandwich gà: 25.000 đ
2. Cà phê sữa: 20.000 đ
TỔNG CỘNG: 45.000 đ
Tiền mặt: 50.000 đ
Tiền thối: 5.000 đ
Cảm ơn quý khách!
''';

      final result = parser.parse(ocrText);
      expect(result.merchantCandidate, 'CIRCLE K VIETNAM');
      expect(result.dateCandidate, isNotNull);
      expect(result.dateCandidate!.year, 2026);
      expect(result.dateCandidate!.month, 10);
      expect(result.dateCandidate!.day, 12);
      expect(result.totalAmountCandidate, 45000);
      expect(result.confidence, greaterThanOrEqualTo(0.9));
    });

    test('2. Mẫu OCR có Subtotal và Grand Total - phải lấy đúng Grand Total', () {
      const ocrText = '''
THE COFFEE HOUSE
Hóa đơn số: #98765
Date: 2026-05-15
Tạm tính: 120.000 đ
Giảm giá voucher: 20.000 đ
GRAND TOTAL: 100,000 VND
Khách đưa: 200,000 VND
Tiền thừa: 100,000 VND
''';

      final result = parser.parse(ocrText);
      expect(result.merchantCandidate, 'THE COFFEE HOUSE');
      expect(result.dateCandidate, isNotNull);
      expect(result.dateCandidate!.year, 2026);
      expect(result.dateCandidate!.month, 5);
      expect(result.dateCandidate!.day, 15);
      expect(result.totalAmountCandidate, 100000);
    });

    test('3. Mẫu OCR thiếu ngày hoặc thiếu tổng tiền', () {
      const ocrTextMissingDate = '''
Highlands Coffee
Hóa đơn thanh toán
1 Trà sen vàng
Thành tiền: 65000 đ
''';

      final result1 = parser.parse(ocrTextMissingDate);
      expect(result1.merchantCandidate, 'Highlands Coffee');
      expect(result1.dateCandidate, isNull);
      expect(result1.totalAmountCandidate, 65000);

      const ocrTextMissingTotal = '''
Phúc Long Tea & Coffee
Ngày: 20/11/2026
Đơn hàng đã hủy
''';

      final result2 = parser.parse(ocrTextMissingTotal);
      expect(result2.merchantCandidate, 'Phúc Long Tea & Coffee');
      expect(result2.dateCandidate, isNotNull);
      expect(result2.totalAmountCandidate, isNull);
    });

    test('4. Mẫu OCR rỗng hoặc chứa chuỗi nhiễu', () {
      final emptyResult = parser.parse('');
      expect(emptyResult.merchantCandidate, isNull);
      expect(emptyResult.dateCandidate, isNull);
      expect(emptyResult.totalAmountCandidate, isNull);
      expect(emptyResult.confidence, 0.0);

      const noisyText = '''
!@#\$%^&*()
1234567890
------
....
''';
      final noisyResult = parser.parse(noisyText);
      expect(noisyResult.merchantCandidate, isNull);
      expect(noisyResult.dateCandidate, isNull);
      expect(noisyResult.totalAmountCandidate, isNull);
    });

    test('5. Hỗ trợ các định dạng tiền có dấu chấm hoặc dấu phẩy', () {
      const dotFormatText = '''
Nhà sách Phương Nam
Ngày: 01/06/2026
TỔNG CỘNG: 1.250.000 đ
''';
      final dotResult = parser.parse(dotFormatText);
      expect(dotResult.totalAmountCandidate, 1250000);

      const commaFormatText = '''
WinMart+
Ngày: 02/06/2026
TỔNG TIỀN: 250,000 đ
''';
      final commaResult = parser.parse(commaFormatText);
      expect(commaResult.totalAmountCandidate, 250000);
    });
  });
}
