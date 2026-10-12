import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/receipt_repository.dart';
import '../../../models/receipt.dart';
import '../../history/screens/receipt_detail_screen.dart';
import '../../history/widgets/receipt_list_tile.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/monthly_expense_chart.dart';

class DashboardScreen extends StatefulWidget {
  final ReceiptRepository? repository;
  final VoidCallback? onNavigateToScan;
  final VoidCallback? onNavigateToHistory;

  const DashboardScreen({
    super.key,
    this.repository,
    this.onNavigateToScan,
    this.onNavigateToHistory,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ReceiptRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;

  int _totalExpenseThisMonth = 0;
  int _receiptCountThisMonth = 0;
  List<Receipt> _recentReceipts = [];
  List<ChartDataPoint> _chartPoints = [];
  bool _isViewingMonthly = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReceiptRepository();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final total = await _repository.getTotalExpenseThisMonth();
      final count = await _repository.getReceiptCountThisMonth();
      final allReceipts = await _repository.getReceipts();

      if (mounted) {
        setState(() {
          _totalExpenseThisMonth = total;
          _receiptCountThisMonth = count;
          _recentReceipts = allReceipts.take(4).toList();

          _chartPoints = _isViewingMonthly
              ? ChartDataAggregator.aggregateMonthly(allReceipts, months: 6)
              : ChartDataAggregator.aggregateDaily(allReceipts, days: 7);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi tải dữ liệu tổng quan: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleChartMode(bool monthly) {
    setState(() {
      _isViewingMonthly = monthly;
    });
    _loadDashboardData();
  }

  Future<void> _openDetail(Receipt receipt) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ReceiptDetailScreen(
          receipt: receipt,
          repository: _repository,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            tooltip: 'Làm mới',
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppTheme.primaryColor,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thẻ tổng quan chi tiêu tháng này
          ExpenseSummaryCard(
            totalExpenseThisMonth: _totalExpenseThisMonth,
            receiptCountThisMonth: _receiptCountThisMonth,
            onTap: widget.onNavigateToHistory,
          ),
          const SizedBox(height: 20),

          // Hai nút thao tác nhanh: Quét hóa đơn & Lịch sử
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text('Quét hóa đơn'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: widget.onNavigateToScan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.history_outlined),
                  label: const Text('Xem lịch sử'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: widget.onNavigateToHistory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tùy chọn phạm vi biểu đồ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biểu đồ chi tiêu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: Row(
                  children: [
                    _buildChartTab(
                      label: '7 ngày',
                      isSelected: !_isViewingMonthly,
                      onTap: () => _toggleChartMode(false),
                    ),
                    _buildChartTab(
                      label: '6 tháng',
                      isSelected: _isViewingMonthly,
                      onTap: () => _toggleChartMode(true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Biểu đồ CustomPainter
          MonthlyExpenseChart(
            dataPoints: _chartPoints,
            title: _isViewingMonthly ? 'Chi tiêu 6 tháng gần nhất' : 'Chi tiêu 7 ngày gần nhất',
          ),
          const SizedBox(height: 24),

          // Danh sách gần đây
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hóa đơn gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (_recentReceipts.isNotEmpty && widget.onNavigateToHistory != null)
                TextButton(
                  onPressed: widget.onNavigateToHistory,
                  child: const Text('Xem tất cả'),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_recentReceipts.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, size: 40, color: AppTheme.textSecondary),
                  const SizedBox(height: 8),
                  const Text(
                    'Chưa có dữ liệu chi tiêu',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hãy quét hóa đơn đầu tiên để bắt đầu theo dõi chi tiêu.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (widget.onNavigateToScan != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Quét hóa đơn ngay'),
                      onPressed: widget.onNavigateToScan,
                    ),
                ],
              ),
            ),
          ] else ...[
            ..._recentReceipts.map(
              (r) => ReceiptListTile(
                receipt: r,
                onTap: () => _openDetail(r),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
