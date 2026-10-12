import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../models/receipt.dart';

class AppDatabase {
  AppDatabase._init();
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableReceipts} (
        ${AppConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppConstants.colMerchant} TEXT NOT NULL,
        ${AppConstants.colTotalAmount} INTEGER NOT NULL,
        ${AppConstants.colReceiptDate} TEXT NOT NULL,
        ${AppConstants.colRawOcrText} TEXT,
        ${AppConstants.colImagePath} TEXT,
        ${AppConstants.colCreatedAt} TEXT NOT NULL,
        ${AppConstants.colUpdatedAt} TEXT
      )
    ''');
  }

  /// Thêm hóa đơn mới vào SQLite
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableReceipts,
      receipt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Lấy tất cả hóa đơn, sắp xếp ngày mới nhất lên đầu
  Future<List<Receipt>> getAllReceipts() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableReceipts,
      orderBy: '${AppConstants.colReceiptDate} DESC, ${AppConstants.colId} DESC',
    );
    return maps.map((m) => Receipt.fromMap(m)).toList();
  }

  /// Lấy hóa đơn theo ID
  Future<Receipt?> getReceiptById(int id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableReceipts,
      where: '${AppConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Receipt.fromMap(maps.first);
    }
    return null;
  }

  /// Cập nhật hóa đơn
  Future<int> updateReceipt(Receipt receipt) async {
    if (receipt.id == null) {
      throw ArgumentError('Receipt id cannot be null for update');
    }
    final db = await database;
    final updateMap = receipt.copyWith(updatedAt: DateTime.now()).toMap();
    return await db.update(
      AppConstants.tableReceipts,
      updateMap,
      where: '${AppConstants.colId} = ?',
      whereArgs: [receipt.id],
    );
  }

  /// Xóa hóa đơn theo ID
  Future<int> deleteReceipt(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableReceipts,
      where: '${AppConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  /// Đóng kết nối database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
