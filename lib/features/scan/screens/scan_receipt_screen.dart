import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/receipt_image_service.dart';
import '../../../services/receipt_parser_service.dart';
import '../../../services/text_recognition_service.dart';
import '../../review/screens/review_receipt_screen.dart';
import '../widgets/ocr_result_preview.dart';

class ScanReceiptScreen extends StatefulWidget {
  final ReceiptImageService? imageService;
  final TextRecognitionService? textRecognitionService;
  final ReceiptParserService? parserService;

  const ScanReceiptScreen({
    super.key,
    this.imageService,
    this.textRecognitionService,
    this.parserService,
  });

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  late final ReceiptImageService _imageService;
  late final TextRecognitionService _textRecognitionService;
  late final ReceiptParserService _parserService;

  String? _selectedImagePath;
  String _ocrRawText = '';
  ReceiptParseResult? _parseResult;
  bool _isProcessing = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _imageService = widget.imageService ?? ReceiptImageService();
    _textRecognitionService = widget.textRecognitionService ?? TextRecognitionService();
    _parserService = widget.parserService ?? ReceiptParserService();
  }

  @override
  void dispose() {
    _textRecognitionService.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessImage({required bool fromCamera}) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = fromCamera ? 'Đang mở máy ảnh...' : 'Đang mở thư viện ảnh...';
    });

    try {
      final imagePath = fromCamera
          ? await _imageService.pickImageFromCamera()
          : await _imageService.pickImageFromGallery();

      if (!mounted) return;

      if (imagePath == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy thao tác chọn ảnh.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() {
        _selectedImagePath = imagePath;
        _statusMessage = _textRecognitionService.isSupported
            ? 'Đang nhận diện chữ qua Google ML Kit...'
            : 'Đang tải ảnh hóa đơn lên trình duyệt...';
      });

      // Thực hiện OCR (hoặc fallback nếu trên Web)
      final text = await _textRecognitionService.processImage(imagePath);
      final parseResult = _parserService.parse(text);

      if (!mounted) return;

      setState(() {
        _ocrRawText = text;
        _parseResult = parseResult;
        _isProcessing = false;
        _statusMessage = '';
      });

      if (text.trim().isEmpty) {
        final isWeb = !_textRecognitionService.isSupported;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isWeb
                  ? 'Chế độ Web: Bạn có thể xem ảnh và nhập thông tin ở màn hình Review.'
                  : 'Không tìm thấy văn bản trên ảnh. Bạn có thể tự điền thông tin.',
            ),
            action: SnackBarAction(
              label: 'Vào Review',
              textColor: Colors.amber,
              onPressed: _navigateToReview,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        // Tự động điều hướng sang màn hình Review để người dùng xác nhận
        _navigateToReview();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xử lý ảnh: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _navigateToReview() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ReviewReceiptScreen(
          parseResult: _parseResult,
          imagePath: _selectedImagePath,
        ),
      ),
    );

    if (result == true && mounted) {
      // Đã lưu thành công, xóa dữ liệu preview và thông báo
      setState(() {
        _selectedImagePath = null;
        _ocrRawText = '';
        _parseResult = null;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedImagePath = null;
      _ocrRawText = '';
      _parseResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét hóa đơn'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh chọn nguồn ảnh (Camera / Gallery)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Chụp ảnh'),
                      onPressed: _isProcessing ? null : () => _pickAndProcessImage(fromCamera: true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Từ thư viện'),
                      onPressed: _isProcessing ? null : () => _pickAndProcessImage(fromCamera: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hiển thị trạng thái Loading
              if (_isProcessing) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _textRecognitionService.isSupported
                            ? 'Xử lý hoàn toàn cục bộ trên thiết bị bằng Google ML Kit'
                            : 'Chế độ Web: Hỗ trợ đối chiếu ảnh và nhập thủ công',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Nếu đã có ảnh và kết quả OCR
              if (_selectedImagePath != null && !_isProcessing) ...[
                OcrResultPreview(
                  imagePath: _selectedImagePath,
                  rawText: _ocrRawText,
                  onClear: _clearSelection,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text(
                    'Kiểm tra & Lưu hóa đơn',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _navigateToReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],

              // Trạng thái trống (Chưa chọn ảnh)
              if (_selectedImagePath == null && !_isProcessing) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.document_scanner_outlined,
                          size: 56,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Chưa chọn hóa đơn nào',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hãy chụp hoặc chọn ảnh hóa đơn rõ nét. Hệ thống sẽ tự động quét thông tin cửa hàng, ngày và số tiền.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFeaturePill(Icons.offline_bolt_outlined, 'OCR Offline'),
                          const SizedBox(width: 8),
                          _buildFeaturePill(Icons.lock_outline, 'Bảo mật 100%'),
                          const SizedBox(width: 8),
                          _buildFeaturePill(Icons.edit_note, 'Tự do sửa'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
