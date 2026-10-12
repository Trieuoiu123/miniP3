import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  TextRecognizer? _textRecognizer;

  bool get isSupported => true;

  TextRecognizer get _recognizer =>
      _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);

  /// Nhận diện văn bản từ ảnh qua Google ML Kit Text Recognition cục bộ
  Future<String> processImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Không tìm thấy file ảnh tại đường dẫn: $imagePath');
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('Lỗi khi nhận diện chữ OCR: $e');
    }
  }

  /// Đóng recognizer và giải phóng tài nguyên
  Future<void> dispose() async {
    final recognizer = _textRecognizer;
    if (recognizer != null) {
      await recognizer.close();
      _textRecognizer = null;
    }
  }
}
