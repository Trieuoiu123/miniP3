import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'app.dart';
import 'data/local/app_database.dart';
import 'data/repositories/receipt_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo databaseFactory cho Web nếu đang chạy trên trình duyệt
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Khởi tạo database SQLite bền vững
  final db = AppDatabase.instance;
  final repository = ReceiptRepository(db: db);

  runApp(ReceiptTrackerApp(repository: repository));
}
