import 'package:flutter/material.dart';
import 'image/app_image_view_io.dart'
    if (dart.library.js_interop) 'image/app_image_view_web.dart' as img_impl;

class AppImageView extends StatelessWidget {
  final String? imagePath;
  final double? height;
  final BoxFit fit;

  const AppImageView({
    super.key,
    required this.imagePath,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.trim().isEmpty) {
      return const Center(
        child: Icon(Icons.receipt_long, size: 40, color: Colors.grey),
      );
    }

    return img_impl.buildReceiptImage(
      imagePath: imagePath!,
      height: height,
      fit: fit,
    );
  }
}
