class AppConstants {
  static const String appTitle = 'Receipt OCR Expense Tracker';

  // Database Constants
  static const String databaseName = 'receipt_expense_tracker.db';
  static const int databaseVersion = 1;
  static const String tableReceipts = 'receipts';

  // Column Names
  static const String colId = 'id';
  static const String colMerchant = 'merchant';
  static const String colTotalAmount = 'total_amount';
  static const String colReceiptDate = 'receipt_date';
  static const String colRawOcrText = 'raw_ocr_text';
  static const String colImagePath = 'image_path';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
}
