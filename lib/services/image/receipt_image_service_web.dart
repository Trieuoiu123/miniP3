import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ReceiptImageService {
  final ImagePicker _picker;

  ReceiptImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Chụp ảnh từ Camera trên Web (thông qua Web Media Capture)
  Future<String?> pickImageFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (file == null) return null;
      // Đọc bytes để tạo Data URL bền vững qua các lần reload trang
      final bytes = await file.readAsBytes();
      final mime = file.mimeType ?? 'image/jpeg';
      return 'data:$mime;base64,${base64Encode(bytes)}';
    } catch (e) {
      return null;
    }
  }

  /// Chọn ảnh từ Thư viện (File dialog trình duyệt)
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null) return null;
      // Đọc bytes để tạo Data URL bền vững qua các lần reload trang
      final bytes = await file.readAsBytes();
      final mime = file.mimeType ?? 'image/jpeg';
      return 'data:$mime;base64,${base64Encode(bytes)}';
    } catch (e) {
      return null;
    }
  }

  /// Trên Web, chuỗi Data URL đã bền vững sẵn
  Future<String?> saveImagePermanently(String tempPath) async {
    return tempPath;
  }

  /// Xóa file ảnh trên Web (không cần thao tác hệ thống tệp)
  Future<void> deleteImageFile(String? imagePath) async {
    // Không cần thực hiện trên trình duyệt
  }
}
