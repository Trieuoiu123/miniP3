import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_ocr_expense_tracker/app.dart';
import 'package:receipt_ocr_expense_tracker/data/repositories/receipt_repository.dart';
import 'package:receipt_ocr_expense_tracker/features/review/screens/review_receipt_screen.dart';
import 'package:receipt_ocr_expense_tracker/models/receipt.dart';
import 'package:receipt_ocr_expense_tracker/services/receipt_parser_service.dart';

class FakeReceiptRepository extends ReceiptRepository {
  final List<Receipt> _storage = [];
  int _nextId = 1;

  @override
  Future<int> addReceipt(Receipt receipt) async {
    final id = _nextId++;
    _storage.add(receipt.copyWith(id: id));
    return id;
  }

  @override
  Future<List<Receipt>> getReceipts() async {
    return List.unmodifiable(_storage);
  }

  @override
  Future<Receipt?> getReceiptById(int id) async {
    try {
      return _storage.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateReceipt(Receipt receipt) async {
    final idx = _storage.indexWhere((r) => r.id == receipt.id);
    if (idx != -1) {
      _storage[idx] = receipt;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteReceipt(int id) async {
    final initialLen = _storage.length;
    _storage.removeWhere((r) => r.id == id);
    return initialLen - _storage.length;
  }

  @override
  Future<int> getTotalExpenseThisMonth() async {
    final now = DateTime.now();
    int sum = 0;
    for (final r in _storage) {
      if (r.receiptDate.year == now.year && r.receiptDate.month == now.month) {
        sum += r.totalAmount;
      }
    }
    return sum;
  }

  @override
  Future<int> getReceiptCountThisMonth() async {
    final now = DateTime.now();
    int count = 0;
    for (final r in _storage) {
      if (r.receiptDate.year == now.year && r.receiptDate.month == now.month) {
        count++;
      }
    }
    return count;
  }
}

void main() {
  group('Widget Tests', () {
    testWidgets('1. App khởi động thành công và hiển thị Dashboard', (WidgetTester tester) async {
      final fakeRepo = FakeReceiptRepository();
      await tester.pumpWidget(ReceiptTrackerApp(repository: fakeRepo));
      await tester.pumpAndSettle();

      expect(find.text('Expense Tracker'), findsOneWidget);
      expect(find.text('Tổng quan'), findsOneWidget);
      expect(find.text('Quét hóa đơn'), findsWidgets);
      expect(find.text('Lịch sử'), findsOneWidget);
    });

    testWidgets('2. NavigationBar chuyển tab mượt mà sang Quét hóa đơn và Lịch sử', (WidgetTester tester) async {
      final fakeRepo = FakeReceiptRepository();
      await tester.pumpWidget(ReceiptTrackerApp(repository: fakeRepo));
      await tester.pumpAndSettle();

      // Nhấn chuyển sang tab Lịch sử
      await tester.tap(find.text('Lịch sử'));
      await tester.pumpAndSettle();
      expect(find.text('Lịch sử chi tiêu'), findsOneWidget);

      // Nhấn chuyển sang tab Quét hóa đơn
      await tester.tap(find.text('Quét hóa đơn').last);
      await tester.pumpAndSettle();
      expect(find.text('Chụp ảnh'), findsOneWidget);
      expect(find.text('Từ thư viện'), findsOneWidget);
    });

    testWidgets('3. Form Review validate khi để trống trường bắt buộc', (WidgetTester tester) async {
      final fakeRepo = FakeReceiptRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: ReviewReceiptScreen(
            repository: fakeRepo,
            parseResult: ReceiptParseResult(rawText: ''),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Nhấn nút lưu khi chưa nhập
      await tester.tap(find.text('Lưu hóa đơn'));
      await tester.pumpAndSettle();

      // Kiểm tra validation errors hiển thị
      expect(find.text('Vui lòng nhập tên cửa hàng'), findsOneWidget);
      expect(find.text('Vui lòng nhập tổng tiền'), findsOneWidget);
    });
  });
}
