import '../local/app_database.dart';
import '../../models/receipt.dart';

class ReceiptRepository {
  final AppDatabase _db;

  ReceiptRepository({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  Future<int> addReceipt(Receipt receipt) async {
    return await _db.insertReceipt(receipt);
  }

  Future<List<Receipt>> getReceipts() async {
    return await _db.getAllReceipts();
  }

  Future<Receipt?> getReceiptById(int id) async {
    return await _db.getReceiptById(id);
  }

  Future<int> updateReceipt(Receipt receipt) async {
    return await _db.updateReceipt(receipt);
  }

  Future<int> deleteReceipt(int id) async {
    return await _db.deleteReceipt(id);
  }

  /// Tính tổng chi tiêu của tháng hiện tại (dựa trên receiptDate)
  Future<int> getTotalExpenseThisMonth() async {
    final receipts = await _db.getAllReceipts();
    final now = DateTime.now();
    int total = 0;
    for (final r in receipts) {
      if (r.receiptDate.year == now.year && r.receiptDate.month == now.month) {
        total += r.totalAmount;
      }
    }
    return total;
  }

  /// Đếm số hóa đơn của tháng hiện tại
  Future<int> getReceiptCountThisMonth() async {
    final receipts = await _db.getAllReceipts();
    final now = DateTime.now();
    int count = 0;
    for (final r in receipts) {
      if (r.receiptDate.year == now.year && r.receiptDate.month == now.month) {
        count++;
      }
    }
    return count;
  }
}
