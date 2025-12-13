import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/admin_service.dart';
import 'admin_login.dart';
import 'dashboard_home.dart';
import 'laporan_management.dart';
import 'user_management.dart';
import 'statistics_page.dart';
import 'settings_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      page: const DashboardHome(),
    ),
    SidebarItem(
      icon: Icons.assignment_rounded,
      label: 'Kelola Laporan',
      page: const LaporanManagement(),
    ),
    SidebarItem(
      icon: Icons.people_rounded,
      label: 'Pengguna',
      page: const UserManagement(),
    ),
    SidebarItem(
      icon: Icons.bar_chart_rounded,
      label: 'Statistik',
      page: const StatisticsPage(),
    ),
    SidebarItem(
      icon: Icons.settings_rounded,
      label: 'Pengaturan',
      page: const SettingsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 800 && screenWidth <= 1200;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar - hidden on mobile
          if (isDesktop || isTablet) _buildSidebar(isDesktop),

          // Main content area
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isDesktop || isTablet),
                Expanded(
                  child: _sidebarItems[_selectedIndex].page,
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom navigation for mobile
      bottomNavigationBar: (!isDesktop && !isTablet)
          ? _buildBottomNavigation()
          : null,
      // Drawer for mobile
      drawer: (!isDesktop && !isTablet)
          ? _buildDrawer()
          : null,
    );
  }

  Widget _buildSidebar(bool isDesktop) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarExpanded ? 260 : 80,
      decoration: const BoxDecoration(
        gradient: AppColors.sidebarGradient,
      ),
      child: Column(
        children: [
          // Logo section
          _buildSidebarHeader(),

          const SizedBox(height: 20),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                return _buildSidebarItem(index);
              },
            ),
          ),

          // User info and logout
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (_isSidebarExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Admin Panel',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          IconButton(
            onPressed: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            icon: Icon(
              _isSidebarExpanded
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final item = _sidebarItems[index];
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _isSidebarExpanded ? 16 : 12,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: _isSidebarExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? AppColors.primary : Colors.white54,
                  size: 22,
                ),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    final adminInfo = _adminService.getCurrentAdminInfo();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (_isSidebarExpanded) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminInfo?['name'] ?? 'Admin',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        adminInfo?['email'] ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _handleLogout,
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade300,
                size: 20,
              ),
              label: _isSidebarExpanded
                  ? Text(
                'Keluar',
                style: GoogleFonts.poppins(
                  color: Colors.red.shade300,
                  fontWeight: FontWeight.w500,
                ),
              )
                  : const SizedBox.shrink(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool showSearchBar) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!showSearchBar)
            Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu_rounded),
                color: AppColors.textPrimary,
              ),
            ),
          Expanded(
            child: Text(
              _sidebarItems[_selectedIndex].label,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (showSearchBar) ...[
            Container(
              width: 300,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          _buildNotificationButton(),
          const SizedBox(width: 12),
          _buildProfileButton(),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          IconButton(
            onPressed: () {
              // Show notifications
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    final adminInfo = _adminService.getCurrentAdminInfo();

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              adminInfo?['name'] ?? 'Admin',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 12),
              Text(
                'Profil',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: 12),
              Text(
                'Pengaturan',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: Colors.red.shade400),
              const SizedBox(width: 12),
              Text(
                'Keluar',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          _handleLogout();
        } else if (value == 'settings') {
          setState(() {
            _selectedIndex = 4; // Settings page index
          });
        }
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex < 4 ? _selectedIndex : 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Pengguna',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.sidebarGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildSidebarHeader(),
            const Divider(color: Colors.white12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _sidebarItems.length,
                itemBuilder: (context, index) {
                  return _buildDrawerItem(index);
                },
              ),
            ),
            _buildSidebarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index) {
    final item = _sidebarItems[index];
    final isSelected = _selectedIndex == index;

    return ListTile(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
      leading: Icon(
        item.icon,
        color: isSelected ? AppColors.primary : Colors.white54,
      ),
      title: Text(
        item.label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Konfirmasi Keluar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari Admin Dashboard?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _adminService.adminLogout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminLoginPage()),
        );
      }
    }
  }
}

class SidebarItem {
  final IconData icon;
  final String label;
  final Widget page;

  SidebarItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}