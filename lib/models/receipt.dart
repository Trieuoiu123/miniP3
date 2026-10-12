import '../core/constants/app_constants.dart';

class Receipt {
  final int? id;
  final String merchant;
  final int totalAmount;
  final DateTime receiptDate;
  final String? rawOcrText;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Receipt({
    this.id,
    required this.merchant,
    required this.totalAmount,
    required this.receiptDate,
    this.rawOcrText,
    this.imagePath,
    DateTime? createdAt,
    this.updatedAt,
  })  : createdAt = createdAt ?? DateTime.now() {
    if (totalAmount < 0) {
      throw ArgumentError.value(
        totalAmount,
        'totalAmount',
        'Tổng tiền không được là số âm.',
      );
    }
  }

  Receipt copyWith({
    int? id,
    String? merchant,
    int? totalAmount,
    DateTime? receiptDate,
    String? rawOcrText,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      totalAmount: totalAmount ?? this.totalAmount,
      receiptDate: receiptDate ?? this.receiptDate,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) AppConstants.colId: id,
      AppConstants.colMerchant: merchant,
      AppConstants.colTotalAmount: totalAmount,
      AppConstants.colReceiptDate: receiptDate.toIso8601String(),
      AppConstants.colRawOcrText: rawOcrText,
      AppConstants.colImagePath: imagePath,
      AppConstants.colCreatedAt: createdAt.toIso8601String(),
      AppConstants.colUpdatedAt: updatedAt?.toIso8601String(),
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    final rawAmount = map[AppConstants.colTotalAmount];
    int parsedAmount = 0;
    if (rawAmount is int) {
      parsedAmount = rawAmount;
    } else if (rawAmount is num) {
      parsedAmount = rawAmount.round();
    } else if (rawAmount is String) {
      parsedAmount = int.tryParse(rawAmount) ?? 0;
    }

    DateTime parsedReceiptDate;
    final rawReceiptDate = map[AppConstants.colReceiptDate];
    if (rawReceiptDate is String) {
      parsedReceiptDate = DateTime.tryParse(rawReceiptDate) ?? DateTime.now();
    } else {
      parsedReceiptDate = DateTime.now();
    }

    DateTime parsedCreatedAt;
    final rawCreatedAt = map[AppConstants.colCreatedAt];
    if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    DateTime? parsedUpdatedAt;
    final rawUpdatedAt = map[AppConstants.colUpdatedAt];
    if (rawUpdatedAt is String && rawUpdatedAt.isNotEmpty) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt);
    }

    return Receipt(
      id: map[AppConstants.colId] as int?,
      merchant: (map[AppConstants.colMerchant] as String?)?.trim() ?? 'Không rõ',
      totalAmount: parsedAmount < 0 ? 0 : parsedAmount,
      receiptDate: parsedReceiptDate,
      rawOcrText: map[AppConstants.colRawOcrText] as String?,
      imagePath: map[AppConstants.colImagePath] as String?,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  @override
  String toString() {
    return 'Receipt(id: $id, merchant: "$merchant", total: $totalAmount đ, date: ${receiptDate.toIso8601String()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Receipt &&
        other.id == id &&
        other.merchant == merchant &&
        other.totalAmount == totalAmount &&
        other.receiptDate == receiptDate &&
        other.rawOcrText == rawOcrText &&
        other.imagePath == imagePath &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      merchant,
      totalAmount,
      receiptDate,
      rawOcrText,
      imagePath,
      createdAt,
      updatedAt,
    );
  }
}
