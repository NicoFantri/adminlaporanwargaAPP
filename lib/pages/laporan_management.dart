import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/admin_service.dart';

class LaporanManagement extends StatefulWidget {
  const LaporanManagement({super.key});

  @override
  State<LaporanManagement> createState() => _LaporanManagementState();
}

class _LaporanManagementState extends State<LaporanManagement> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _allReports = [];
  List<Map<String, dynamic>> _filteredReports = [];

  String _selectedStatus = 'Semua';
  String _selectedPriority = 'Semua';
  String _searchQuery = '';
  String _sortBy = 'Terbaru';

  final List<String> _statusOptions = [
    'Semua', 'Baru', 'Sedang Ditinjau', 'Sedang Dikerjakan', 'Selesai', 'Ditolak',
  ];

  final List<String> _priorityOptions = ['Semua', 'Urgent', 'High', 'Medium', 'Low'];

  final List<String> _sortOptions = [
    'Terbaru', 'Terlama', 'Prioritas Tertinggi', 'Prioritas Terendah',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      setState(() => _isLoading = true);
      final reports = await _adminService.getAllLaporan();
      setState(() {
        _allReports = reports;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat laporan', isError: true);
    }
  }

  void _applyFilters() {
    var filtered = List<Map<String, dynamic>>.from(_allReports);

    if (_selectedStatus != 'Semua') {
      filtered = filtered.where((r) => r['status'] == _selectedStatus).toList();
    }

    if (_selectedPriority != 'Semua') {
      filtered = filtered.where((r) => r['priority'] == _selectedPriority).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final title = (r['title'] ?? '').toString().toLowerCase();
        final location = (r['location'] ?? '').toString().toLowerCase();
        final category = (r['category'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || location.contains(query) || category.contains(query);
      }).toList();
    }

    switch (_sortBy) {
      case 'Terbaru':
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
          final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
        break;
      case 'Terlama':
        filtered.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
          final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
          return dateA.compareTo(dateB);
        });
        break;
      case 'Prioritas Tertinggi':
        final priorityOrder = {'Urgent': 4, 'High': 3, 'Medium': 2, 'Low': 1};
        filtered.sort((a, b) => (priorityOrder[b['priority']] ?? 0).compareTo(priorityOrder[a['priority']] ?? 0));
        break;
      case 'Prioritas Terendah':
        final priorityOrder = {'Urgent': 4, 'High': 3, 'Medium': 2, 'Low': 1};
        filtered.sort((a, b) => (priorityOrder[a['priority']] ?? 0).compareTo(priorityOrder[b['priority']] ?? 0));
        break;
    }

    setState(() => _filteredReports = filtered);
  }

  Future<void> _updateStatus(String reportId, String newStatus) async {
    try {
      await _adminService.updateLaporanStatus(reportId, newStatus);
      _showSnackBar('Status berhasil diubah');
      await _loadReports();
    } catch (e) {
      _showSnackBar('Gagal mengubah status', isError: true);
    }
  }

  Future<void> _deleteReport(String reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Laporan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus laporan ini?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _adminService.deleteLaporan(reportId);
        _showSnackBar('Laporan berhasil dihapus');
        await _loadReports();
      } catch (e) {
        _showSnackBar('Gagal menghapus laporan', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.poppins()),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildReportsTable(isDesktop),
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
              Text('Kelola Laporan', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('${_filteredReports.length} dari ${_allReports.length} laporan ditampilkan', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _loadReports,
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari laporan berdasarkan judul, lokasi, atau kategori...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.backgroundSecondary,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildFilterDropdown('Status', _selectedStatus, _statusOptions, (value) { _selectedStatus = value!; _applyFilters(); }),
              _buildFilterDropdown('Prioritas', _selectedPriority, _priorityOptions, (value) { _selectedPriority = value!; _applyFilters(); }),
              _buildFilterDropdown('Urutkan', _sortBy, _sortOptions, (value) { _sortBy = value!; _applyFilters(); }),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedStatus = 'Semua';
                    _selectedPriority = 'Semua';
                    _searchQuery = '';
                    _sortBy = 'Terbaru';
                  });
                  _applyFilters();
                },
                icon: const Icon(Icons.clear_all_rounded, size: 20),
                label: Text('Reset Filter', style: GoogleFonts.poppins(fontSize: 14)),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text('$label: $item', style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildReportsTable(bool isDesktop) {
    if (_isLoading) {
      return Container(
        height: 400,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredReports.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text('Tidak ada laporan ditemukan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: isDesktop ? _buildDesktopTable() : _buildMobileList(),
    );
  }

  Widget _buildDesktopTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.backgroundSecondary),
          headingTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
          dataTextStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
          columnSpacing: 30,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Judul')),
            DataColumn(label: Text('Kategori')),
            DataColumn(label: Text('Lokasi')),
            DataColumn(label: Text('Pelapor')),
            DataColumn(label: Text('Prioritas')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Tanggal')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: _filteredReports.map((report) {
            return DataRow(cells: [
              DataCell(Text(report['id']?.toString().substring(0, 8) ?? '-', style: GoogleFonts.poppins(fontWeight: FontWeight.w500))),
              DataCell(SizedBox(width: 200, child: Text(report['title'] ?? 'Tanpa Judul', overflow: TextOverflow.ellipsis))),
              DataCell(_buildBadge(report['category'] ?? '-', AppColors.primary)),
              DataCell(SizedBox(width: 150, child: Text(report['location'] ?? '-', overflow: TextOverflow.ellipsis))),
              DataCell(Text(report['reporter_name'] ?? 'Anonim')),
              DataCell(_buildBadge(report['priority'] ?? 'Medium', AppColors.getPriorityColor(report['priority'] ?? 'Medium'))),
              DataCell(_buildStatusDropdown(report)),
              DataCell(Text(_formatDate(report['created_at']))),
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(onPressed: () => _showReportDetail(report), icon: const Icon(Icons.visibility_outlined), color: AppColors.info, iconSize: 20),
                IconButton(onPressed: () => _deleteReport(report['id']), icon: const Icon(Icons.delete_outline), color: AppColors.error, iconSize: 20),
              ])),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredReports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = _filteredReports[index];
        final status = report['status'] ?? 'Baru';
        final priority = report['priority'] ?? 'Medium';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(report['title'] ?? 'Tanpa Judul', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'view', child: Row(children: [const Icon(Icons.visibility, size: 18), const SizedBox(width: 8), Text('Lihat Detail', style: GoogleFonts.poppins(fontSize: 14))])),
                      PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red.shade400), const SizedBox(width: 8), Text('Hapus', style: GoogleFonts.poppins(fontSize: 14, color: Colors.red.shade400))])),
                    ],
                    onSelected: (value) {
                      if (value == 'view') _showReportDetail(report);
                      else if (value == 'delete') _deleteReport(report['id']);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [Icon(Icons.location_on_outlined, size: 16, color: AppColors.textLight), const SizedBox(width: 6), Expanded(child: Text(report['location'] ?? '-', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis))]),
              const SizedBox(height: 12),
              Row(children: [
                _buildBadge(priority, AppColors.getPriorityColor(priority)),
                const SizedBox(width: 8),
                _buildBadge(status, AppColors.getStatusColor(status)),
                const Spacer(),
                Text(_formatDate(report['created_at']), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight)),
              ]),
              const SizedBox(height: 12),
              _buildStatusDropdown(report),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildStatusDropdown(Map<String, dynamic> report) {
    final currentStatus = report['status'] ?? 'Baru';
    final statusOptions = ['Baru', 'Sedang Ditinjau', 'Sedang Dikerjakan', 'Selesai', 'Ditolak'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getStatusColor(currentStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.getStatusColor(currentStatus).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
          items: statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status, style: GoogleFonts.poppins(color: AppColors.getStatusColor(status))))).toList(),
          onChanged: (newStatus) {
            if (newStatus != null && newStatus != currentStatus) {
              _updateStatus(report['id'], newStatus);
            }
          },
        ),
      ),
    );
  }

  void _showReportDetail(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                child: Row(children: [
                  Expanded(child: Text('Detail Laporan', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                ]),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [_buildBadge(report['priority'] ?? 'Medium', AppColors.getPriorityColor(report['priority'] ?? 'Medium')), const SizedBox(width: 8), _buildBadge(report['status'] ?? 'Baru', AppColors.getStatusColor(report['status'] ?? 'Baru'))]),
                      const SizedBox(height: 20),
                      Text(report['title'] ?? 'Tanpa Judul', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 20),
                      _buildDetailRow(Icons.category_outlined, 'Kategori', report['category'] ?? '-'),
                      _buildDetailRow(Icons.location_on_outlined, 'Lokasi', report['location'] ?? '-'),
                      _buildDetailRow(Icons.person_outline, 'Pelapor', report['reporter_name'] ?? 'Anonim'),
                      _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal', _formatDate(report['created_at'])),
                      if (report['admin_notes'] != null && report['admin_notes'].toString().isNotEmpty)
                        _buildDetailRow(Icons.note_outlined, 'Catatan Admin', report['admin_notes']),
                      const SizedBox(height: 20),
                      Text('Deskripsi', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: BorderRadius.circular(12)),
                        child: Text(report['description'] ?? 'Tidak ada deskripsi', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
                      ),
                      if (report['image_urls'] != null && (report['image_urls'] as List).isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('Foto Lampiran', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (report['image_urls'] as List).length,
                            itemBuilder: (context, index) => Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(report['image_urls'][index]), fit: BoxFit.cover)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); _deleteReport(report['id']); },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text('Hapus', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.textLight),
        const SizedBox(width: 12),
        SizedBox(width: 100, child: Text(label, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
      ]),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}