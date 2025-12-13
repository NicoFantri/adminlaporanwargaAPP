import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/admin_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  Map<String, int> _categoryStats = {};
  List<Map<String, dynamic>> _allReports = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() => _isLoading = true);

      final stats = await _adminService.getStatistics();
      final categoryStats = await _adminService.getCategoryStatistics();
      final reports = await _adminService.getAllLaporan();

      setState(() {
        _statistics = stats;
        _categoryStats = categoryStats;
        _allReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildOverviewCards(isDesktop),
            const SizedBox(height: 24),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStatusDistribution()),
                  const SizedBox(width: 24),
                  Expanded(child: _buildPriorityDistribution()),
                ],
              )
            else ...[
              _buildStatusDistribution(),
              const SizedBox(height: 24),
              _buildPriorityDistribution(),
            ],
            const SizedBox(height: 24),
            _buildCategoryDistribution(),
            const SizedBox(height: 24),
            _buildMonthlyTrend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistik & Analitik',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pantau perkembangan laporan infrastruktur',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _loadStatistics,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: Text('Refresh', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(bool isDesktop) {
    final items = [
      _OverviewItem(
        title: 'Total Laporan',
        value: _statistics['total']?.toString() ?? '0',
        icon: Icons.assignment_rounded,
        color: AppColors.primary,
        subtitle: 'Semua laporan yang masuk',
      ),
      _OverviewItem(
        title: 'Tingkat Penyelesaian',
        value: _calculateCompletionRate(),
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
        subtitle: 'Laporan yang diselesaikan',
      ),
      _OverviewItem(
        title: 'Rata-rata Waktu',
        value: '3.5 hari',
        icon: Icons.schedule_rounded,
        color: AppColors.info,
        subtitle: 'Waktu penyelesaian',
      ),
      _OverviewItem(
        title: 'Laporan Urgent',
        value: _statistics['urgent']?.toString() ?? '0',
        icon: Icons.priority_high_rounded,
        color: AppColors.error,
        subtitle: 'Perlu penanganan segera',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.4 : 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (_isLoading) {
          return _buildLoadingCard();
        }
        return _buildOverviewCard(items[index]);
      },
    );
  }

  String _calculateCompletionRate() {
    final total = _statistics['total'] ?? 0;
    final selesai = _statistics['selesai'] ?? 0;
    if (total == 0) return '0%';
    return '${((selesai / total) * 100).toStringAsFixed(1)}%';
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildOverviewCard(_OverviewItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const Spacer(),
          Text(
            item.value,
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(item.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Text(item.subtitle, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution() {
    final statusData = [
      _ChartData('Baru', _statistics['baru'] ?? 0, AppColors.warning),
      _ChartData('Sedang Ditinjau', _statistics['sedangDitinjau'] ?? 0, AppColors.info),
      _ChartData('Sedang Dikerjakan', _statistics['sedangDikerjakan'] ?? 0, AppColors.primary),
      _ChartData('Selesai', _statistics['selesai'] ?? 0, AppColors.success),
      _ChartData('Ditolak', _statistics['ditolak'] ?? 0, AppColors.error),
    ];

    return _buildChartCard(
      title: 'Distribusi Status',
      subtitle: 'Pembagian laporan berdasarkan status',
      child: _buildBarChart(statusData),
    );
  }

  Widget _buildPriorityDistribution() {
    final priorityData = [
      _ChartData('Urgent', _statistics['urgent'] ?? 0, AppColors.error),
      _ChartData('High', _statistics['high'] ?? 0, AppColors.warning),
      _ChartData('Medium', _statistics['medium'] ?? 0, AppColors.info),
      _ChartData('Low', _statistics['low'] ?? 0, AppColors.success),
    ];

    return _buildChartCard(
      title: 'Distribusi Prioritas',
      subtitle: 'Pembagian laporan berdasarkan prioritas',
      child: _buildBarChart(priorityData),
    );
  }

  Widget _buildCategoryDistribution() {
    return _buildChartCard(
      title: 'Distribusi Kategori',
      subtitle: 'Pembagian laporan berdasarkan jenis masalah',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categoryStats.isEmpty
          ? Center(child: Text('Tidak ada data', style: GoogleFonts.poppins(color: AppColors.textSecondary)))
          : _buildCategoryChart(),
    );
  }

  Widget _buildCategoryChart() {
    final total = _statistics['total'] ?? 1;
    final sortedCategories = _categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        final percentage = (category.value / total * 100).toStringAsFixed(1);
        final color = AppColors.chartColors[index % AppColors.chartColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 8),
                      Text(category.key, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  Text('${category.value} ($percentage%)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: category.value / total,
                  backgroundColor: AppColors.backgroundSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyTrend() {
    return _buildChartCard(
      title: 'Tren Bulanan',
      subtitle: 'Jumlah laporan per bulan',
      child: _buildMonthlyChart(),
    );
  }

  Widget _buildMonthlyChart() {
    final monthlyData = _calculateMonthlyData();
    final maxValue = monthlyData.values.isEmpty ? 1 : monthlyData.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: monthlyData.entries.map((entry) {
          final height = maxValue > 0 ? (entry.value / maxValue * 150) : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                entry.value.toString(),
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: height.toDouble(),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(entry.key, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Map<String, int> _calculateMonthlyData() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    final currentMonth = DateTime.now().month;
    final data = <String, int>{};

    // Get last 6 months
    for (int i = 5; i >= 0; i--) {
      int monthIndex = currentMonth - 1 - i;
      if (monthIndex < 0) monthIndex += 12;
      data[months[monthIndex]] = 0;
    }

    // Count reports per month
    for (final report in _allReports) {
      try {
        final date = DateTime.parse(report['created_at']);
        final monthKey = months[date.month - 1];
        if (data.containsKey(monthKey)) {
          data[monthKey] = (data[monthKey] ?? 0) + 1;
        }
      } catch (e) {
        // Skip invalid dates
      }
    }

    return data;
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildBarChart(List<_ChartData> data) {
    final total = data.fold<int>(0, (sum, item) => sum + item.value);
    final maxValue = data.isEmpty ? 1 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Column(
      children: data.map((item) {
        final percentage = total > 0 ? (item.value / total * 100).toStringAsFixed(1) : '0';
        final barWidth = maxValue > 0 ? item.value / maxValue : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 8),
                      Text(item.label, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  Text('${item.value} ($percentage%)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: barWidth,
                  backgroundColor: AppColors.backgroundSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(item.color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _OverviewItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  _OverviewItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}

class _ChartData {
  final String label;
  final int value;
  final Color color;

  _ChartData(this.label, this.value, this.color);
}