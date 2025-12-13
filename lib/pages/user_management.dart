import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/admin_service.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      final users = await _adminService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data pengguna', isError: true);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final name = (user['display_name'] ?? user['username'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
        }).toList();
      }
    });
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
      onRefresh: _loadUsers,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildUsersTable(isDesktop),
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
                'Manajemen Pengguna',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_filteredUsers.length} pengguna terdaftar',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _loadUsers,
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        onChanged: _filterUsers,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cari pengguna berdasarkan nama atau email...',
          hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight),
          filled: true,
          fillColor: AppColors.backgroundSecondary,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildUsersTable(bool isDesktop) {
    if (_isLoading) {
      return Container(
        height: 400,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredUsers.isEmpty) {
      return Container(
        height: 400,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text('Tidak ada pengguna ditemukan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
          columnSpacing: 40,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('Pengguna')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Username')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Bergabung')),
            DataColumn(label: Text('Status')),
          ],
          rows: _filteredUsers.map((user) {
            return DataRow(cells: [
              DataCell(_buildUserCell(user)),
              DataCell(Text(user['email'] ?? '-')),
              DataCell(Text(user['username'] ?? '-')),
              DataCell(_buildRoleBadge(user['is_admin'])),
              DataCell(Text(_formatDate(user['created_at']))),
              DataCell(_buildStatusBadge(user['is_active'] ?? true)),
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
      itemCount: _filteredUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildMobileUserCard(user);
      },
    );
  }

  Widget _buildMobileUserCard(Map<String, dynamic> user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['display_name'] ?? user['username'] ?? 'Pengguna',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    Text(
                      user['email'] ?? '-',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _buildRoleBadge(user['is_admin']),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textLight),
              const SizedBox(width: 8),
              Text('Bergabung: ${_formatDate(user['created_at'])}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              _buildStatusBadge(user['is_active'] ?? true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCell(Map<String, dynamic> user) {
    return Row(
      children: [
        _buildAvatar(user),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user['display_name'] ?? user['username'] ?? 'Pengguna',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            if (user['phone'] != null)
              Text(
                user['phone'],
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(Map<String, dynamic> user) {
    final profileUrl = user['profile_picture_url'];
    final name = user['display_name'] ?? user['username'] ?? 'U';
    final initial = name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : 'U';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: profileUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(profileUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitial(initial)),
      )
          : _buildInitial(initial),
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildRoleBadge(bool? isAdmin) {
    final admin = isAdmin == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: admin ? AppColors.warning.withOpacity(0.1) : AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        admin ? 'Admin' : 'User',
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: admin ? AppColors.warning : AppColors.info),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? AppColors.success : AppColors.error),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}