class DateParser {
  /// Định dạng DateTime thành chuỗi hiển thị 'dd/MM/yyyy'
  static String format(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  /// Định dạng DateTime thành chuỗi chuẩn ISO 8601 chỉ gồm ngày: 'yyyy-MM-dd'
  static String formatIsoDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$year-$month-$day';
  }

  /// Kiểm tra xem năm/tháng/ngày có thực sự hợp lệ trong lịch Gregorian không.
  /// Ngăn chặn DateTime tự cuộn (ví dụ 31/02 thành 03/03).
  static bool isValidDate(int year, int month, int day) {
    if (year < 1900 || year > 2100) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1) return false;

    final daysInMonth = _getDaysInMonth(year, month);
    return day <= daysInMonth;
  }

  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month];
  }

  /// Phân tích chuỗi ngày từ các định dạng thông dụng:
  /// - dd/MM/yyyy hoặc d/M/yyyy
  /// - dd-MM-yyyy hoặc d-M-yyyy
  /// - yyyy-MM-dd
  /// - yyyy/MM/dd
  /// - dd.MM.yyyy
  /// Trả về null nếu không hợp lệ hoặc ngày không tồn tại (như 31/02/2026).
  static DateTime? parse(String? input) {
    if (input == null) return null;
    final text = input.trim();
    if (text.isEmpty) return null;

    // 1. Thử regex yyyy-MM-dd hoặc yyyy/MM/dd
    final isoRegex = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$');
    final isoMatch = isoRegex.firstMatch(text);
    if (isoMatch != null) {
      final year = int.tryParse(isoMatch.group(1)!);
      final month = int.tryParse(isoMatch.group(2)!);
      final day = int.tryParse(isoMatch.group(3)!);
      if (year != null && month != null && day != null) {
        if (isValidDate(year, month, day)) {
          return DateTime(year, month, day);
        }
      }
      return null;
    }

    // 2. Thử regex dd/MM/yyyy hoặc dd-MM-yyyy hoặc dd.MM.yyyy
    final dmyRegex = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})$');
    final dmyMatch = dmyRegex.firstMatch(text);
    if (dmyMatch != null) {
      final day = int.tryParse(dmyMatch.group(1)!);
      final month = int.tryParse(dmyMatch.group(2)!);
      final year = int.tryParse(dmyMatch.group(3)!);
      if (day != null && month != null && year != null) {
        if (isValidDate(year, month, day)) {
          return DateTime(year, month, day);
        }
      }
      return null;
    }

    // 3. Thử parse ISO đầy đủ (ví dụ DateTime.toIso8601String())
    final parsedIso = DateTime.tryParse(text);
    if (parsedIso != null) {
      if (isValidDate(parsedIso.year, parsedIso.month, parsedIso.day)) {
        return DateTime(parsedIso.year, parsedIso.month, parsedIso.day);
      }
    }

    return null;
  }
}
