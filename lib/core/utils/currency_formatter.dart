class CurrencyFormatter {
  /// Định dạng số nguyên VND sang chuỗi có dấu chấm phân cách hàng nghìn và hậu tố ' đ'
  /// Ví dụ:
  ///   0 -> '0 đ'
  ///   15000 -> '15.000 đ'
  ///   250000 -> '250.000 đ'
  ///   1250000 -> '1.250.000 đ'
  static String format(int amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toString();

    final buffer = StringBuffer();
    for (int i = 0; i < absAmount.length; i++) {
      if (i > 0 && (absAmount.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(absAmount[i]);
    }

    final result = buffer.toString();
    return isNegative ? '-$result đ' : '$result đ';
  }

  /// Định dạng ngắn gọn cho nhãn trục biểu đồ hoặc thẻ nhỏ nếu cần (ví dụ: 1.2M, 500k)
  static String formatCompact(int amount) {
    if (amount >= 1000000000) {
      final val = (amount / 1000000000).toStringAsFixed(1).replaceAll('.0', '');
      return '${val}B đ';
    } else if (amount >= 1000000) {
      final val = (amount / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return '${val}M đ';
    } else if (amount >= 1000) {
      final val = (amount / 1000).toStringAsFixed(0);
      return '${val}k đ';
    }
    return '$amount đ';
  }

  /// Phân tích chuỗi số tiền VND thành số nguyên [int]
  /// Hỗ trợ các định dạng: '1.250.000', '1,250,000', '1250000', '1250000 đ'
  /// Trả về null nếu không hợp lệ hoặc âm
  static int? parse(String? input) {
    if (input == null) return null;
    final cleaned = input
        .trim()
        .toLowerCase()
        .replaceAll('đ', '')
        .replaceAll('vnd', '')
        .replaceAll('d', '')
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('.', '');

    if (cleaned.isEmpty) return null;
    final val = int.tryParse(cleaned);
    if (val == null || val < 0) return null;
    return val;
  }
}
