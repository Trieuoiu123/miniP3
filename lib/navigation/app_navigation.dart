import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/receipt_repository.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/history/screens/receipt_history_screen.dart';
import '../features/scan/screens/scan_receipt_screen.dart';

class AppNavigation extends StatefulWidget {
  final ReceiptRepository? repository;

  const AppNavigation({
    super.key,
    this.repository,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;
  late final ReceiptRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReceiptRepository();
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tái tạo các trang theo index hiện tại để đảm bảo reload dữ liệu mới nhất
    final pages = [
      DashboardScreen(
        repository: _repository,
        onNavigateToScan: () => _navigateToTab(1),
        onNavigateToHistory: () => _navigateToTab(2),
      ),
      ScanReceiptScreen(),
      ReceiptHistoryScreen(
        repository: _repository,
        onNavigateToScan: () => _navigateToTab(1),
      ),
    ];

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryColor),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner, color: AppTheme.primaryColor),
            label: 'Quét hóa đơn',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppTheme.primaryColor),
            label: 'Lịch sử',
          ),
        ],
      ),
    );
  }
}
