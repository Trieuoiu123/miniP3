class TextRecognitionService {
  bool get isSupported => false;

  /// Trên nền tảng Web, Google ML Kit native không hỗ trợ trực tiếp.
  /// Trả về chuỗi rỗng để luồng chuyển tiếp sang màn hình Review với Fallback
  /// cho phép người dùng xem ảnh đối chiếu và tự do nhập/chỉnh sửa thông tin.
  Future<String> processImage(String imagePath) async {
    return '';
  }

  Future<void> dispose() async {
    // Không cần đóng tài nguyên native trên Web
  }
}
