import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_format.dart';
import '../../services/analytics_service.dart';
import '../../models/analytics.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '7days';
  Analytics? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    // Xóa các SnackBar cũ
    ScaffoldMessenger.of(context).clearSnackBars();
    
    try {
      print('📊 Loading analytics for period: $_selectedPeriod');
      final analytics = await AnalyticsService.getAnalytics(_selectedPeriod);
      print('✅ Analytics loaded successfully');
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading analytics: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: _loadAnalytics,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Thống kê', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analytics == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Không có dữ liệu'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadAnalytics,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 20),
                      _buildStatsCards(),
                      const SizedBox(height: 20),
                      _buildRevenueChart(),
                      const SizedBox(height: 20),
                      _buildOrdersChart(),
                      const SizedBox(height: 20),
                      _buildTopProducts(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton('7 ngày', '7days'),
          _buildPeriodButton('30 ngày', '30days'),
          _buildPeriodButton('3 tháng', '3months'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPeriod = value);
          _loadAnalytics();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.getSecondaryTextColor(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_analytics == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Doanh thu',
            formatCurrency(_analytics!.totalRevenue),
            Icons.attach_money,
            AppTheme.successColor,
            '${_analytics!.revenueGrowth >= 0 ? '+' : ''}${_analytics!.revenueGrowth.toStringAsFixed(1)}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Đơn hàng',
            _analytics!.totalOrders.toString(),
            Icons.shopping_bag,
            AppTheme.primaryColor,
            '${_analytics!.ordersGrowth >= 0 ? '+' : ''}${_analytics!.ordersGrowth.toStringAsFixed(1)}%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryTextColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (_analytics == null || _analytics!.revenueChart.isEmpty) {
      return const SizedBox();
    }
    
    final spots = _analytics!.revenueChart.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value / 1000000);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _selectedPeriod == '7days' ? 1 : null,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _analytics!.revenueChart.length) {
                          return Text(
                            _analytics!.revenueChart[index].label,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart() {
    if (_analytics == null) return const SizedBox();

    final statusMap = _analytics!.ordersByStatus;
    final total = statusMap.values.fold(0, (sum, val) => sum + val);
    
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Chưa có đơn hàng')),
      );
    }

    final sections = <PieChartSectionData>[];
    if (statusMap['DELIVERED']! > 0) {
      sections.add(PieChartSectionData(
        value: statusMap['DELIVERED']!.toDouble(),
        title: '${(statusMap['DELIVERED']! * 100 / total).toStringAsFixed(0)}%',
        color: AppTheme.successColor,
        radius: 50,
      ));
    }
    if (statusMap['SHIPPING']! > 0) {
      sections.add(PieChartSectionData(
        value: statusMap['SHIPPING']!.toDouble(),
        title: '${(statusMap['SHIPPING']! * 100 / total).toStringAsFixed(0)}%',
        color: AppTheme.primaryColor,
        radius: 50,
      ));
    }
    if (statusMap['PENDING']! > 0) {
      sections.add(PieChartSectionData(
        value: statusMap['PENDING']!.toDouble(),
        title: '${(statusMap['PENDING']! * 100 / total).toStringAsFixed(0)}%',
        color: AppTheme.warningColor,
        radius: 50,
      ));
    }
    if (statusMap['CANCELLED']! > 0) {
      sections.add(PieChartSectionData(
        value: statusMap['CANCELLED']!.toDouble(),
        title: '${(statusMap['CANCELLED']! * 100 / total).toStringAsFixed(0)}%',
        color: Colors.red,
        radius: 50,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đơn hàng theo trạng thái',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Đã giao', AppTheme.successColor),
        _buildLegendItem('Đang giao', AppTheme.primaryColor),
        _buildLegendItem('Chờ xử lý', AppTheme.warningColor),
        _buildLegendItem('Đã hủy', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildTopProducts() {
    if (_analytics == null || _analytics!.topProducts.isEmpty) {
      return const SizedBox();
    }

    final topProducts = _analytics!.topProducts.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm bán chạy',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...topProducts.map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[200],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${product.soldQuantity} đã bán',
                            style: TextStyle(color: AppTheme.getSecondaryTextColor(context), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatCurrency(product.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
