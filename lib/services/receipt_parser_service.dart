import '../core/utils/currency_formatter.dart';
import '../core/utils/date_parser.dart';

class ReceiptParseResult {
  final String? merchantCandidate;
  final DateTime? dateCandidate;
  final int? totalAmountCandidate;
  final String rawText;
  final double confidence; // 0.0 -> 1.0

  ReceiptParseResult({
    this.merchantCandidate,
    this.dateCandidate,
    this.totalAmountCandidate,
    required this.rawText,
    this.confidence = 0.0,
  });

  @override
  String toString() {
    return 'ReceiptParseResult(merchant: "$merchantCandidate", date: $dateCandidate, total: $totalAmountCandidate)';
  }
}

class ReceiptParserService {
  /// Parse văn bản OCR thô và trích xuất gợi ý
  ReceiptParseResult parse(String? rawText) {
    if (rawText == null || rawText.trim().isEmpty) {
      return ReceiptParseResult(rawText: '');
    }

    final cleanedText = rawText.trim();
    final lines = cleanedText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final merchant = _extractMerchant(lines);
    final date = _extractDate(lines, cleanedText);
    final total = _extractTotalAmount(lines);

    int score = 0;
    if (merchant != null && merchant.isNotEmpty) score++;
    if (date != null) score++;
    if (total != null && total > 0) score++;
    final confidence = score / 3.0;

    return ReceiptParseResult(
      merchantCandidate: merchant,
      dateCandidate: date,
      totalAmountCandidate: total,
      rawText: cleanedText,
      confidence: confidence,
    );
  }

  /// Trích xuất tên cửa hàng (Merchant)
  String? _extractMerchant(List<String> lines) {
    final ignoredPatterns = [
      RegExp(r'^(hóa đơn|phiếu thanh toán|phiếu tính tiền|hóa đơn bán lẻ|hóa đơn vat|receipt|invoice|bill)', caseSensitive: false),
      RegExp(r'^(chào mừng|welcome|cảm ơn|thank you|xin chào)', caseSensitive: false),
      RegExp(r'^(địa chỉ|đ/c|address|add|tel|phone|sđt|hotline|fax|mst|mã số thuế|wifi|pass)', caseSensitive: false),
      RegExp(r'^\d+$'), // Chỉ gồm chữ số
      RegExp(r'^[^\w\s]+$'), // Chỉ ký tự đặc biệt
    ];

    for (int i = 0; i < lines.length && i < 6; i++) {
      final line = lines[i];
      if (line.length < 2) continue;

      bool shouldIgnore = false;
      for (final p in ignoredPatterns) {
        if (p.hasMatch(line)) {
          shouldIgnore = true;
          break;
        }
      }

      if (!shouldIgnore) {
        // Làm sạch chuỗi
        final cleaned = line
            .replaceAll(RegExp(r'^[#*\-•\s]+'), '')
            .replaceAll(RegExp(r'[#*\-•\s]+$'), '')
            .trim();
        if (cleaned.isNotEmpty && cleaned.length >= 2) {
          return cleaned;
        }
      }
    }
    return null;
  }

  /// Trích xuất ngày từ dòng hoặc toàn văn bản
  DateTime? _extractDate(List<String> lines, String fullText) {
    // 1. Thử tìm trên các dòng có từ khóa date/ngày trước
    final dateKeywordRegex = RegExp(r'(ngày|ngay|date|thời gian|time)\s*[:.]?\s*(\d{1,4}[-/. ]\d{1,2}[-/. ]\d{1,4})', caseSensitive: false);
    for (final line in lines) {
      final match = dateKeywordRegex.firstMatch(line);
      if (match != null) {
        final dateStr = match.group(2);
        final parsed = DateParser.parse(dateStr);
        if (parsed != null) return parsed;
      }
    }

    // 2. Tìm mẫu dd/MM/yyyy hoặc dd-MM-yyyy hoặc yyyy-MM-dd ở bất cứ đâu trong text
    final generalDateRegex = RegExp(r'\b(\d{1,2}[-/. ]\d{1,2}[-/. ]\d{4})\b|\b(\d{4}[-/. ]\d{1,2}[-/. ]\d{1,2})\b');
    final matches = generalDateRegex.allMatches(fullText);
    for (final m in matches) {
      final matchStr = m.group(0);
      final parsed = DateParser.parse(matchStr);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  /// Trích xuất tổng tiền
  int? _extractTotalAmount(List<String> lines) {
    final grandTotalKeywords = [
      'tổng cộng',
      'tong cong',
      'tổng tiền',
      'tong tien',
      'thành tiền',
      'thanh tien',
      'thanh toan',
      'thanh toán',
      'tiền thanh toán',
      'tổng thanh toán',
      'tổng phải trả',
      'grand total',
      'total amount',
      'amount due',
      'total',
    ];

    final excludeKeywords = [
      'tiền khách đưa',
      'khách đưa',
      'tien khach dua',
      'tiền thối',
      'tiền thừa',
      'tien thua',
      'change',
      'cash',
      'điểm tích lũy',
      'giảm giá',
      'chiết khấu',
      'discount',
      'subtotal',
      'tạm tính',
      'tam tinh',
    ];

    // Duyệt từ cuối danh sách dòng lên đầu để ưu tiên các dòng tổng kết quả
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final lower = line.toLowerCase();

      // Kiểm tra có chứa từ khóa loại trừ không
      bool isExcluded = false;
      for (final ex in excludeKeywords) {
        if (lower.contains(ex)) {
          isExcluded = true;
          break;
        }
      }
      if (isExcluded) continue;

      // Kiểm tra có chứa từ khóa tổng không
      bool hasTotalKeyword = false;
      for (final kw in grandTotalKeywords) {
        if (lower.contains(kw)) {
          hasTotalKeyword = true;
          break;
        }
      }

      if (hasTotalKeyword) {
        // Trích xuất số tiền trong dòng này
        final amount = _extractAmountFromLine(line);
        if (amount != null && amount > 0) {
          return amount;
        }

        // Nếu dòng hiện tại chỉ có chữ "Tổng cộng:" mà số nằm ở dòng kế tiếp
        if (i + 1 < lines.length) {
          final nextLineAmount = _extractAmountFromLine(lines[i + 1]);
          if (nextLineAmount != null && nextLineAmount > 0) {
            return nextLineAmount;
          }
        }
      }
    }

    // Fallback: Tìm các dòng có "CỘNG" hoặc tìm số tiền cuối cùng hợp lý
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final lower = line.toLowerCase();
      if (lower.contains('cộng') || lower.contains('cong')) {
        final amount = _extractAmountFromLine(line);
        if (amount != null && amount > 0) return amount;
      }
    }

    return null;
  }

  /// Trích xuất số tiền từ một dòng văn bản
  int? _extractAmountFromLine(String line) {
    // Tìm các chuỗi số có dạng tiền: 250.000, 250,000, 250000, có thể kèm 'đ' hoặc 'vnd'
    final moneyRegex = RegExp(r'(\d{1,3}(?:[.,]\d{3})+(?:\s*(?:đ|vnd))?|\d{4,9}(?:\s*(?:đ|vnd))?)', caseSensitive: false);
    final matches = moneyRegex.allMatches(line);
    if (matches.isNotEmpty) {
      // Ưu tiên số cuối cùng trên dòng
      final lastMatch = matches.last.group(0);
      return CurrencyFormatter.parse(lastMatch);
    }
    return null;
  }
}
