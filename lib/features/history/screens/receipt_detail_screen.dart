import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_parser.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../data/repositories/receipt_repository.dart';
import '../../../models/receipt.dart';
import '../../../services/receipt_image_service.dart';
import '../../review/screens/review_receipt_screen.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final Receipt receipt;
  final ReceiptRepository? repository;
  final ReceiptImageService? imageService;

  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
    this.repository,
    this.imageService,
  });

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  late final ReceiptRepository _repository;
  late final ReceiptImageService _imageService;
  late Receipt _receipt;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReceiptRepository();
    _imageService = widget.imageService ?? ReceiptImageService();
    _receipt = widget.receipt;
    _reloadReceipt();
  }

  Future<void> _reloadReceipt() async {
    if (_receipt.id == null) return;
    setState(() => _isLoading = true);
    final fresh = await _repository.getReceiptById(_receipt.id!);
    if (mounted) {
      if (fresh != null) {
        setState(() {
          _receipt = fresh;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleEdit() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ReviewReceiptScreen(
          existingReceipt: _receipt,
          repository: _repository,
          imageService: _imageService,
        ),
      ),
    );

    if (updated == true && mounted) {
      await _reloadReceipt();
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa hóa đơn'),
        content: Text(
          'Bạn có chắc chắn muốn xóa hóa đơn "${_receipt.merchant}" trị giá ${CurrencyFormatter.format(_receipt.totalAmount)} không? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        if (_receipt.id != null) {
          await _repository.deleteReceipt(_receipt.id!);
        }
        if (_receipt.imagePath != null) {
          await _imageService.deleteImageFile(_receipt.imagePath);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa hóa đơn thành công!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa hóa đơn: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hóa đơn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
            tooltip: 'Chỉnh sửa',
            onPressed: _handleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            tooltip: 'Xóa',
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Thẻ tổng tiền nổi bật
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'TỔNG TIỀN THANH TOÁN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyFormatter.format(_receipt.totalAmount),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  DateParser.format(_receipt.receiptDate),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Thông tin cửa hàng và ngày tạo
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.storefront,
                            label: 'Cửa hàng / Đơn vị',
                            value: _receipt.merchant,
                          ),
                          const Divider(color: AppTheme.dividerColor, height: 24),
                          _buildDetailRow(
                            icon: Icons.event_note,
                            label: 'Ngày trên hóa đơn',
                            value: DateParser.format(_receipt.receiptDate),
                          ),
                          const Divider(color: AppTheme.dividerColor, height: 24),
                          _buildDetailRow(
                            icon: Icons.access_time,
                            label: 'Thời gian lưu hệ thống',
                            value: DateParser.format(_receipt.createdAt),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Ảnh đính kèm (nếu có)
                    if (_receipt.imagePath != null && _receipt.imagePath!.isNotEmpty) ...[
                      const Text(
                        'Ảnh hóa đơn đã chụp/chọn',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.dividerColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: AppImageView(
                            imagePath: _receipt.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Văn bản OCR thô
                    if (_receipt.rawOcrText != null && _receipt.rawOcrText!.isNotEmpty) ...[
                      const Text(
                        'Văn bản OCR nhận diện được',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: SelectableText(
                          _receipt.rawOcrText!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            height: 1.5,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Nút chỉnh sửa / xóa dưới chân
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Chỉnh sửa'),
                            onPressed: _handleEdit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Xóa hóa đơn'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                            ),
                            onPressed: _handleDelete,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
