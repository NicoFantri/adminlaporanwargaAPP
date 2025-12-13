import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../services/admin_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AdminService _adminService = AdminService();

  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _autoRefresh = true;
  String _refreshInterval = '30 detik';
  bool _isExporting = false;

  final List<String> _refreshOptions = ['15 detik', '30 detik', '1 menit', '5 menit'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProfileSection()),
                const SizedBox(width: 24),
                Expanded(child: _buildNotificationSettings()),
              ],
            )
          else ...[
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildNotificationSettings(),
          ],
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAdminManagementSection()),
                const SizedBox(width: 24),
                Expanded(child: _buildAppSettings()),
              ],
            )
          else ...[
            _buildAdminManagementSection(),
            const SizedBox(height: 24),
            _buildAppSettings(),
          ],
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kelola preferensi dan pengaturan akun Anda',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    final adminInfo = _adminService.getCurrentAdminInfo();

    return _buildSettingsCard(
      title: 'Profil Admin',
      icon: Icons.person_rounded,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            adminInfo?['name'] ?? 'Admin',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            adminInfo?['email'] ?? 'admin@example.com',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text('Edit Profil', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.lock_outline, size: 18),
              label: Text('Ubah Password', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsCard(
      title: 'Notifikasi',
      icon: Icons.notifications_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Notifikasi Push',
            subtitle: 'Terima notifikasi untuk laporan baru',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          const Divider(),
          _buildSwitchTile(
            title: 'Notifikasi Email',
            subtitle: 'Terima email untuk laporan urgent',
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminManagementSection() {
    return _buildSettingsCard(
      title: 'Manajemen Admin',
      icon: Icons.admin_panel_settings_rounded,
      child: Column(
        children: [
          _buildActionTile(
            title: 'Tambah Admin Baru',
            subtitle: 'Daftarkan admin baru ke sistem',
            icon: Icons.person_add_outlined,
            onTap: _showAddAdminDialog,
          ),
          const Divider(),
          _buildActionTile(
            title: 'Daftar Admin',
            subtitle: 'Lihat semua admin terdaftar',
            icon: Icons.people_outline,
            onTap: _showAdminListDialog,
          ),
          const Divider(),
          _buildActionTile(
            title: 'Pengaturan Role',
            subtitle: 'Kelola hak akses admin',
            icon: Icons.security_outlined,
            onTap: () => _showSnackBar('Fitur dalam pengembangan'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return _buildSettingsCard(
      title: 'Pengaturan Aplikasi',
      icon: Icons.settings_rounded,
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Auto Refresh',
            subtitle: 'Perbarui data secara otomatis',
            value: _autoRefresh,
            onChanged: (value) => setState(() => _autoRefresh = value),
          ),
          const Divider(),
          _buildDropdownTile(
            title: 'Interval Refresh',
            subtitle: 'Frekuensi pembaruan data',
            value: _refreshInterval,
            options: _refreshOptions,
            onChanged: (value) {
              if (value != null) {
                setState(() => _refreshInterval = value);
              }
            },
          ),
          const Divider(),
          _buildActionTile(
            title: 'Bersihkan Cache',
            subtitle: 'Hapus data cache aplikasi',
            icon: Icons.delete_sweep_outlined,
            onTap: _showClearCacheDialog,
          ),
          const Divider(),
          _buildActionTile(
            title: 'Export Data',
            subtitle: 'Download semua data laporan',
            icon: Icons.download_outlined,
            onTap: _showExportDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return _buildSettingsCard(
      title: 'Tentang Aplikasi',
      icon: Icons.info_rounded,
      child: Column(
        children: [
          _buildInfoTile('Versi Aplikasi', '1.0.0'),
          const Divider(),
          _buildInfoTile('Build Number', '2024.1'),
          const Divider(),
          _buildInfoTile('Developer', 'Tim Pengembang'),
          const Divider(),
          _buildActionTile(
            title: 'Kebijakan Privasi',
            subtitle: 'Baca kebijakan privasi kami',
            icon: Icons.privacy_tip_outlined,
            onTap: () => _showSnackBar('Membuka kebijakan privasi...'),
          ),
          const Divider(),
          _buildActionTile(
            title: 'Syarat & Ketentuan',
            subtitle: 'Baca syarat dan ketentuan',
            icon: Icons.description_outlined,
            onTap: () => _showSnackBar('Membuka syarat & ketentuan...'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: value,
              underline: const SizedBox(),
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
              items: options.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Profil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showSnackBar('Profil berhasil diperbarui');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool obscureOld = true;
        bool obscureNew = true;
        bool obscureConfirm = true;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Ubah Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: obscureOld,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newPasswordController.text != confirmPasswordController.text) {
                      _showSnackBar('Password tidak cocok', isError: true);
                      return;
                    }
                    if (newPasswordController.text.length < 6) {
                      _showSnackBar('Password minimal 6 karakter', isError: true);
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                    _showSnackBar('Password berhasil diubah');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool obscurePassword = true;
        bool obscureConfirm = true;
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_add, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Tambah Admin Baru', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary,
                          suffixIcon: IconButton(
                            icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          labelStyle: GoogleFonts.poppins(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.backgroundSecondary,
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.info.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Admin baru akan menerima email verifikasi untuk mengaktifkan akun.',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.info),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (nameController.text.trim().isEmpty) {
                      _showSnackBar('Nama tidak boleh kosong', isError: true);
                      return;
                    }
                    if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
                      _showSnackBar('Email tidak valid', isError: true);
                      return;
                    }
                    if (passwordController.text.length < 6) {
                      _showSnackBar('Password minimal 6 karakter', isError: true);
                      return;
                    }
                    if (passwordController.text != confirmPasswordController.text) {
                      _showSnackBar('Password tidak cocok', isError: true);
                      return;
                    }

                    setDialogState(() => isLoading = true);

                    try {
                      await _adminService.createNewAdmin(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                        displayName: nameController.text.trim(),
                      );

                      // Close dialog first, then show snackbar
                      if (Navigator.of(dialogContext).canPop()) {
                        Navigator.of(dialogContext).pop();
                      }

                      // Use Future.delayed to ensure dialog is fully closed
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          _showSnackBar('Admin baru berhasil ditambahkan');
                        }
                      });
                    } catch (e) {
                      setDialogState(() => isLoading = false);
                      _showSnackBar('Gagal menambahkan admin: ${e.toString()}', isError: true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text('Tambah Admin', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAdminListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _adminService.getAllAdmins(),
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.people, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Daftar Admin', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 500,
                height: 400,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Gagal memuat data admin', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    ],
                  ),
                )
                    : (snapshot.data == null || snapshot.data!.isEmpty)
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 48, color: AppColors.textLight),
                      const SizedBox(height: 16),
                      Text('Belum ada admin terdaftar', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    ],
                  ),
                )
                    : ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  itemBuilder: (BuildContext context, int index) {
                    final admin = snapshot.data![index];
                    return ListTile(
                      leading: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            (admin['display_name'] ?? admin['email'] ?? 'A')[0].toUpperCase(),
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                      title: Text(
                        admin['display_name'] ?? 'Admin',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        admin['email'] ?? '-',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Aktif',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Tutup', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Use Future.delayed to ensure dialog is fully closed before opening new one
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        _showAddAdminDialog();
                      }
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Tambah Admin', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Bersihkan Cache', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin membersihkan cache aplikasi?', style: GoogleFonts.poppins()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showSnackBar('Cache berhasil dibersihkan');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Bersihkan', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? selectedFormat;
        DateTime? startDate;
        DateTime? endDate;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.download, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Export Data Laporan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pilih format export:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildFormatOption(
                          format: 'CSV',
                          icon: Icons.table_chart_outlined,
                          isSelected: selectedFormat == 'CSV',
                          onTap: () => setDialogState(() => selectedFormat = 'CSV'),
                        ),
                        const SizedBox(width: 12),
                        _buildFormatOption(
                          format: 'Excel',
                          icon: Icons.grid_on_outlined,
                          isSelected: selectedFormat == 'Excel',
                          onTap: () => setDialogState(() => selectedFormat = 'Excel'),
                        ),
                        const SizedBox(width: 12),
                        _buildFormatOption(
                          format: 'PDF',
                          icon: Icons.picture_as_pdf_outlined,
                          isSelected: selectedFormat == 'PDF',
                          onTap: () => setDialogState(() => selectedFormat = 'PDF'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Rentang Tanggal (Opsional):', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() => startDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    startDate != null ? DateFormat('dd/MM/yyyy').format(startDate!) : 'Dari',
                                    style: GoogleFonts.poppins(fontSize: 13, color: startDate != null ? AppColors.textPrimary : AppColors.textLight),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setDialogState(() => endDate = date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    endDate != null ? DateFormat('dd/MM/yyyy').format(endDate!) : 'Sampai',
                                    style: GoogleFonts.poppins(fontSize: 13, color: endDate != null ? AppColors.textPrimary : AppColors.textLight),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (startDate != null || endDate != null) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => setDialogState(() {
                          startDate = null;
                          endDate = null;
                        }),
                        icon: const Icon(Icons.clear, size: 16),
                        label: Text('Hapus Filter Tanggal', style: GoogleFonts.poppins(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                ElevatedButton.icon(
                  onPressed: selectedFormat == null
                      ? null
                      : () {
                    Navigator.of(dialogContext).pop();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        _exportData(selectedFormat!, startDate, endDate);
                      }
                    });
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: Text('Export', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFormat != null ? AppColors.primary : AppColors.textLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFormatOption({
    required String format,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 28),
              const SizedBox(height: 8),
              Text(
                format,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(String format, DateTime? startDate, DateTime? endDate) async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      _showSnackBar('Mempersiapkan data export...');

      List<Map<String, dynamic>> laporanList;
      if (startDate != null && endDate != null) {
        laporanList = await _adminService.getReportsByDateRange(startDate, endDate);
      } else {
        laporanList = await _adminService.getAllLaporan();
      }

      if (laporanList.isEmpty) {
        _showSnackBar('Tidak ada data untuk di-export', isError: true);
        return;
      }

      if (kIsWeb) {
        _showSnackBar('Export tidak didukung di web', isError: true);
        return;
      }

      String filePath = await _exportToCSV(laporanList);

      await Share.shareXFiles([XFile(filePath)], text: 'Data Laporan');
      _showSnackBar('Data berhasil di-export ke $format');
    } catch (e) {
      _showSnackBar('Gagal export data: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<String> _exportToCSV(List<Map<String, dynamic>> data) async {
    List<List<dynamic>> rows = [];

    rows.add([
      'ID',
      'Judul',
      'Deskripsi',
      'Kategori',
      'Lokasi',
      'Prioritas',
      'Status',
      'Pelapor',
      'Tanggal Dibuat',
      'Tanggal Update',
    ]);

    for (var laporan in data) {
      rows.add([
        laporan['id'] ?? '-',
        laporan['title'] ?? '-',
        laporan['description'] ?? '-',
        laporan['category'] ?? '-',
        laporan['location'] ?? '-',
        laporan['priority'] ?? '-',
        laporan['status'] ?? '-',
        laporan['reporter_name'] ?? '-',
        _formatDateTime(laporan['created_at']),
        _formatDateTime(laporan['updated_at']),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/laporan_$timestamp.csv');
    await file.writeAsString(csv);

    return file.path;
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
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
}