import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReceiptImageService {
  final ImagePicker _picker;

  ReceiptImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Chụp ảnh từ Camera
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (file == null) return null;
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Chọn ảnh từ Thư viện (Gallery)
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return null;
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Sao chép ảnh từ đường dẫn tạm sang thư mục ứng dụng bền vững
  Future<String?> saveImagePermanently(String tempPath) async {
    try {
      final tempFile = File(tempPath);
      if (!await tempFile.exists()) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(p.join(appDir.path, 'receipt_images'));
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}${p.extension(tempPath)}';
      final savedImage = await tempFile.copy(p.join(receiptsDir.path, fileName));
      return savedImage.path;
    } catch (e) {
      return null;
    }
  }

  /// Xóa file ảnh an toàn khi xóa hóa đơn
  Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
