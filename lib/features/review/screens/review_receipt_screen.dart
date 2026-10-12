import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_parser.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../data/repositories/receipt_repository.dart';
import '../../../models/receipt.dart';
import '../../../services/receipt_image_service.dart';
import '../../../services/receipt_parser_service.dart';

class ReviewReceiptScreen extends StatefulWidget {
  final ReceiptParseResult? parseResult;
  final String? imagePath;
  final Receipt? existingReceipt;
  final ReceiptRepository? repository;
  final ReceiptImageService? imageService;

  const ReviewReceiptScreen({
    super.key,
    this.parseResult,
    this.imagePath,
    this.existingReceipt,
    this.repository,
    this.imageService,
  });

  @override
  State<ReviewReceiptScreen> createState() => _ReviewReceiptScreenState();
}

class _ReviewReceiptScreenState extends State<ReviewReceiptScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _merchantController;
  late final TextEditingController _totalController;
  late final TextEditingController _dateController;

  late final ReceiptRepository _repository;
  late final ReceiptImageService _imageService;

  DateTime? _selectedDate;
  String? _currentImagePath;
  bool _isSaving = false;
  bool _showOcrText = false;
  String _rawOcrText = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReceiptRepository();
    _imageService = widget.imageService ?? ReceiptImageService();

    if (widget.existingReceipt != null) {
      final r = widget.existingReceipt!;
      _merchantController = TextEditingController(text: r.merchant);
      _totalController = TextEditingController(text: r.totalAmount.toString());
      _selectedDate = r.receiptDate;
      _dateController = TextEditingController(text: DateParser.format(r.receiptDate));
      _currentImagePath = r.imagePath;
      _rawOcrText = r.rawOcrText ?? '';
    } else {
      final p = widget.parseResult;
      _merchantController = TextEditingController(text: p?.merchantCandidate ?? '');
      _totalController = TextEditingController(
        text: p?.totalAmountCandidate != null ? p!.totalAmountCandidate.toString() : '',
      );
      _selectedDate = p?.dateCandidate ?? DateTime.now();
      _dateController = TextEditingController(
        text: p?.dateCandidate != null ? DateParser.format(p!.dateCandidate!) : DateParser.format(_selectedDate!),
      );
      _currentImagePath = widget.imagePath;
      _rawOcrText = p?.rawText ?? '';
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _totalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateParser.format(picked);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày hóa đơn hợp lệ'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final totalAmount = CurrencyFormatter.parse(_totalController.text);
    if (totalAmount == null || totalAmount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tổng tiền không hợp lệ hoặc bị âm.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? savedImagePath = _currentImagePath;

      // Lưu ảnh lâu dài vào thư mục ứng dụng nếu ảnh mới từ camera/gallery
      if (_currentImagePath != null &&
          widget.existingReceipt?.imagePath != _currentImagePath) {
        final permanent = await _imageService.saveImagePermanently(_currentImagePath!);
        if (permanent != null) {
          savedImagePath = permanent;
        }
      }

      if (widget.existingReceipt != null) {
        // Cập nhật hóa đơn cũ
        final updatedReceipt = widget.existingReceipt!.copyWith(
          merchant: _merchantController.text.trim(),
          totalAmount: totalAmount,
          receiptDate: _selectedDate!,
          imagePath: savedImagePath,
          rawOcrText: _rawOcrText.isNotEmpty ? _rawOcrText : null,
          updatedAt: DateTime.now(),
        );
        await _repository.updateReceipt(updatedReceipt);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật hóa đơn thành công!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        // Thêm hóa đơn mới
        final newReceipt = Receipt(
          merchant: _merchantController.text.trim(),
          totalAmount: totalAmount,
          receiptDate: _selectedDate!,
          rawOcrText: _rawOcrText.isNotEmpty ? _rawOcrText : null,
          imagePath: savedImagePath,
          createdAt: DateTime.now(),
        );
        await _repository.addReceipt(newReceipt);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã lưu hóa đơn vào lịch sử thành công!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu hóa đơn: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReceipt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa hóa đơn' : 'Kiểm tra & Lưu hóa đơn'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thông báo gợi ý
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Kết quả OCR mang tính gợi ý. Hãy kiểm tra và chỉnh sửa trước khi xác nhận lưu.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryDark,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Ảnh xem trước nếu có
                if (_currentImagePath != null && _currentImagePath!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: AppImageView(
                        imagePath: _currentImagePath,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Trường Tên cửa hàng
                const Text(
                  'Tên cửa hàng / Đơn vị bán (*)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _merchantController,
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: Circle K, Phúc Long, WinMart...',
                    prefixIcon: Icon(Icons.storefront, color: AppTheme.primaryColor),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập tên cửa hàng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Trường Tổng tiền
                const Text(
                  'Tổng tiền (VND) (*)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _totalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: 45000',
                    prefixIcon: const Icon(Icons.payments_outlined, color: AppTheme.primaryColor),
                    suffixText: 'VNĐ',
                    helperText: _totalController.text.isNotEmpty &&
                            CurrencyFormatter.parse(_totalController.text) != null
                        ? 'Định dạng: ${CurrencyFormatter.format(CurrencyFormatter.parse(_totalController.text)!)}'
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập tổng tiền';
                    }
                    final parsed = CurrencyFormatter.parse(val);
                    if (parsed == null || parsed < 0) {
                      return 'Số tiền không hợp lệ hoặc âm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Trường Ngày hóa đơn
                const Text(
                  'Ngày hóa đơn (*)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    hintText: 'dd/MM/yyyy',
                    prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit_calendar, color: AppTheme.primaryColor),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng chọn ngày hóa đơn';
                    }
                    if (DateParser.parse(val) == null) {
                      return 'Ngày không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Xem văn bản OCR thô (collapsible)
                if (_rawOcrText.isNotEmpty) ...[
                  OutlinedButton.icon(
                    icon: Icon(_showOcrText ? Icons.visibility_off : Icons.visibility),
                    label: Text(_showOcrText ? 'Ẩn văn bản OCR gốc' : 'Xem văn bản OCR gốc để đối chiếu'),
                    onPressed: () => setState(() => _showOcrText = !_showOcrText),
                  ),
                  if (_showOcrText) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _rawOcrText,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', height: 1.4),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],

                // Nút Lưu hóa đơn
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    child: _isSaving
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Đang lưu vào SQLite...'),
                            ],
                          )
                        : Text(
                            isEditing ? 'Cập nhật hóa đơn' : 'Lưu hóa đơn',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}
}
