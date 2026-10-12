import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_image_view.dart';

class OcrResultPreview extends StatelessWidget {
  final String? imagePath;
  final String rawText;
  final VoidCallback? onClear;

  const OcrResultPreview({
    super.key,
    this.imagePath,
    required this.rawText,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imagePath != null && imagePath!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: AppImageView(
                imagePath: imagePath!,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, size: 20, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Văn bản OCR nhận diện được',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (onClear != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
                      onPressed: onClear,
                      tooltip: 'Xóa ảnh đã chọn',
                    ),
                ],
              ),
              const Divider(color: AppTheme.dividerColor, height: 20),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    rawText.isEmpty ? '(Không nhận diện được văn bản nào)' : rawText,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
