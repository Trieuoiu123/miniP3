import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/receipt_repository.dart';
import '../../../models/receipt.dart';
import '../widgets/receipt_list_tile.dart';
import 'receipt_detail_screen.dart';

class ReceiptHistoryScreen extends StatefulWidget {
  final ReceiptRepository? repository;
  final VoidCallback? onNavigateToScan;

  const ReceiptHistoryScreen({
    super.key,
    this.repository,
    this.onNavigateToScan,
  });

  @override
  State<ReceiptHistoryScreen> createState() => _ReceiptHistoryScreenState();
}

class _ReceiptHistoryScreenState extends State<ReceiptHistoryScreen> {
  late final ReceiptRepository _repository;
  final TextEditingController _searchController = TextEditingController();

  List<Receipt> _allReceipts = [];
  List<Receipt> _filteredReceipts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ReceiptRepository();
    _searchController.addListener(_filterReceipts);
    _loadReceipts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReceipts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final receipts = await _repository.getReceipts();
      if (mounted) {
        setState(() {
          _allReceipts = receipts;
          _isLoading = false;
        });
        _filterReceipts();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải danh sách hóa đơn: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterReceipts() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredReceipts = List.from(_allReceipts));
    } else {
      setState(() {
        _filteredReceipts = _allReceipts
            .where((r) => r.merchant.toLowerCase().contains(query))
            .toList();
      });
    }
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
      _loadReceipts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử chi tiêu'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadReceipts,
          color: AppTheme.primaryColor,
          child: Column(
            children: [
              // Thanh tìm kiếm
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên cửa hàng...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _filterReceipts();
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Nội dung danh sách / Trạng thái
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                onPressed: _loadReceipts,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allReceipts.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 56,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chưa có hóa đơn nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lịch sử chi tiêu sẽ hiển thị tại đây sau khi bạn chụp hoặc chọn hóa đơn để lưu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              if (widget.onNavigateToScan != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Quét hóa đơn ngay'),
                  onPressed: widget.onNavigateToScan,
                ),
            ],
          ),
        ),
      );
    }

    if (_filteredReceipts.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy hóa đơn nào khớp với từ khóa tìm kiếm.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _filteredReceipts.length,
      itemBuilder: (context, index) {
        final receipt = _filteredReceipts[index];
        return ReceiptListTile(
          receipt: receipt,
          onTap: () => _openDetail(receipt),
        );
      },
    );
  }
}
