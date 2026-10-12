import 'dart:io';
import 'package:flutter/material.dart';

Widget buildReceiptImage({
  required String imagePath,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return Image.file(
    File(imagePath),
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, size: 36, color: Colors.grey),
            SizedBox(height: 8),
            Text('Không thể tải file ảnh.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
}
