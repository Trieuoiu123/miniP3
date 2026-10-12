import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/receipt_repository.dart';
import 'navigation/app_navigation.dart';

class ReceiptTrackerApp extends StatelessWidget {
  final ReceiptRepository? repository;

  const ReceiptTrackerApp({
    super.key,
    this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AppNavigation(repository: repository),
    );
  }
}
