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
            Expanded(child: Text(message, style: GoogleFonts.poppins())),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Show dialog to send message to a specific user
  void _showSendMessageDialog(Map<String, dynamic> user) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'message';
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kirim Pesan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Kepada: ${user['display_name'] ?? user['username'] ?? 'Pengguna'}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Message Type Selection
                Text(
                  'Tipe Pesan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeChip('message', 'Pesan', Icons.chat_bubble_outline, selectedType, (type) {
                      setDialogState(() => selectedType = type);
                    }),
                    _buildTypeChip('info', 'Info', Icons.info_outline, selectedType, (type) {
                      setDialogState(() => selectedType = type);
                    }),
                    _buildTypeChip('warning', 'Peringatan', Icons.warning_amber_outlined, selectedType, (type) {
                      setDialogState(() => selectedType = type);
                    }),
                    _buildTypeChip('announcement', 'Pengumuman', Icons.campaign_outlined, selectedType, (type) {
                      setDialogState(() => selectedType = type);
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Title Field
                Text(
                  'Judul Pesan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Masukkan judul pesan...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
                    prefixIcon: const Icon(Icons.title, color: AppColors.textLight, size: 20),
                    filled: true,
                    fillColor: AppColors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Message Field
                Text(
                  'Isi Pesan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan Anda di sini...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
                    filled: true,
                    fillColor: AppColors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                if (titleController.text.trim().isEmpty) {
                  _showSnackBar('Judul pesan tidak boleh kosong', isError: true);
                  return;
                }
                if (messageController.text.trim().isEmpty) {
                  _showSnackBar('Isi pesan tidak boleh kosong', isError: true);
                  return;
                }

                setDialogState(() => isSending = true);

                try {
                  await _adminService.sendMessageToUser(
                    userId: user['id'],
                    title: titleController.text.trim(),
                    message: messageController.text.trim(),
                    type: selectedType,
                  );

                  if (mounted && Navigator.canPop(dialogContext)) {
                    Navigator.pop(dialogContext);
                  }

                  _showSnackBar('Pesan berhasil dikirim ke ${user['display_name'] ?? user['username'] ?? 'pengguna'}');
                } catch (e) {
                  setDialogState(() => isSending = false);
                  _showSnackBar('Gagal mengirim pesan: $e', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isSending
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('Kirim', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show dialog to send broadcast message to all users
  void _showBroadcastDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'announcement';
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Broadcast Pesan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Kirim ke semua pengguna',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pesan ini akan dikirim ke semua pengguna yang terdaftar.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Message Type Selection
                Text(
                  'Tipe Pesan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeChip('announcement', 'Pengumuman', Icons.campaign_outlined, selectedType, (type) {
                      setDialogState(() => selectedType = type);
                    }),
                    _buildTypeChip('info', 'Info', Icons.info_outline, selectedType, (type) {
                      setDialogState(() => selectedType = type);
                    }),
                    _buildTypeChip('warning', 'Peringatan', Icons.warning_amber_outlined, selectedType, (type) {
                      setDialogState(() => selectedType = type);
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Title Field
                Text(
                  'Judul Pesan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Masukkan judul pesan...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
                    prefixIcon: const Icon(Icons.title, color: AppColors.textLight, size: 20),
                    filled: true,
                    fillColor: AppColors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Message Field
                Text(
                  'Isi Pesan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Tulis pesan Anda di sini...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 14),
                    filled: true,
                    fillColor: AppColors.backgroundSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                if (titleController.text.trim().isEmpty) {
                  _showSnackBar('Judul pesan tidak boleh kosong', isError: true);
                  return;
                }
                if (messageController.text.trim().isEmpty) {
                  _showSnackBar('Isi pesan tidak boleh kosong', isError: true);
                  return;
                }

                setDialogState(() => isSending = true);

                try {
                  final count = await _adminService.sendBroadcastMessage(
                    title: titleController.text.trim(),
                    message: messageController.text.trim(),
                    type: selectedType,
                  );

                  if (mounted && Navigator.canPop(dialogContext)) {
                    Navigator.pop(dialogContext);
                  }

                  _showSnackBar('Pesan berhasil dikirim ke $count pengguna');
                } catch (e) {
                  setDialogState(() => isSending = false);
                  _showSnackBar('Gagal mengirim broadcast: $e', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isSending
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.campaign_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('Broadcast', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show chat history with a user
  void _showChatHistory(Map<String, dynamic> user) async {
    showDialog(
      context: context,
      builder: (dialogContext) => _ChatHistoryDialog(
        user: user,
        adminService: _adminService,
        onSendMessage: () => _showSendMessageDialog(user),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon, String selectedType, Function(String) onSelect) {
    final isSelected = type == selectedType;
    Color chipColor;

    switch (type) {
      case 'warning':
        chipColor = AppColors.warning;
        break;
      case 'info':
        chipColor = AppColors.info;
        break;
      case 'announcement':
        chipColor = AppColors.secondary;
        break;
      default:
        chipColor = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => onSelect(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : chipColor,
              ),
            ),
          ],
        ),
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
        // Broadcast Button
        ElevatedButton.icon(
          onPressed: _showBroadcastDialog,
          icon: const Icon(Icons.campaign_rounded, size: 20),
          label: Text('Broadcast', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(width: 12),
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
            DataColumn(label: Text('Aksi')),
          ],
          rows: _filteredUsers.map((user) {
            return DataRow(cells: [
              DataCell(_buildUserCell(user)),
              DataCell(Text(user['email'] ?? '-')),
              DataCell(Text(user['username'] ?? '-')),
              DataCell(_buildRoleBadge(user['is_admin'])),
              DataCell(Text(_formatDate(user['created_at']))),
              DataCell(_buildStatusBadge(user['is_active'] ?? true)),
              DataCell(_buildActionButtons(user)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> user) {
    final isAdmin = user['is_admin'] == true;

    // Don't show chat button for admin users
    if (isAdmin) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Send Message Button
        Tooltip(
          message: 'Kirim Pesan',
          child: IconButton(
            onPressed: () => _showSendMessageDialog(user),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 18),
            ),
          ),
        ),
        // Chat History Button
        Tooltip(
          message: 'Riwayat Pesan',
          child: IconButton(
            onPressed: () => _showChatHistory(user),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.history_rounded, color: AppColors.info, size: 18),
            ),
          ),
        ),
      ],
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
    final isAdmin = user['is_admin'] == true;

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
          // Action buttons for mobile (only for non-admin users)
          if (!isAdmin) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSendMessageDialog(user),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text('Kirim Pesan', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showChatHistory(user),
                    icon: const Icon(Icons.history_rounded, size: 16),
                    label: Text('Riwayat', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: const BorderSide(color: AppColors.info),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

// Chat History Dialog Widget
class _ChatHistoryDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final AdminService adminService;
  final VoidCallback onSendMessage;

  const _ChatHistoryDialog({
    required this.user,
    required this.adminService,
    required this.onSendMessage,
  });

  @override
  State<_ChatHistoryDialog> createState() => _ChatHistoryDialogState();
}

class _ChatHistoryDialogState extends State<_ChatHistoryDialog> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoading = true);
      final messages = await widget.adminService.getMessagesForUser(widget.user['id']);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'info':
        return Icons.info_outline;
      case 'announcement':
        return Icons.campaign_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      case 'announcement':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Pesan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.user['display_name'] ?? widget.user['username'] ?? 'Pengguna',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: SizedBox(
        width: 500,
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _messages.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text(
                'Belum ada pesan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kirim pesan pertama ke pengguna ini',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final message = _messages[index];
            final typeColor = _getTypeColor(message['type']);
            final typeIcon = _getTypeIcon(message['type']);
            final isRead = message['is_read'] == true;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRead ? Colors.white : typeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRead ? AppColors.border : typeColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(typeIcon, color: typeColor, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message['title'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Belum dibaca',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message['message'] ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(message['created_at']),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Tutup',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            widget.onSendMessage();
          },
          icon: const Icon(Icons.send_rounded, size: 18),
          label: Text('Kirim Pesan Baru', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}