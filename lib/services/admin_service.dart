import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final _supabase = Supabase.instance.client;

  // Get all laporan with user details
  Future<List<Map<String, dynamic>>> getAllLaporan() async {
    try {
      final response = await _supabase
          .from('laporan')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching laporan: $e');
      throw Exception('Gagal memuat laporan');
    }
  }

  // Get laporan by status
  Future<List<Map<String, dynamic>>> getLaporanByStatus(String status) async {
    try {
      final response = await _supabase
          .from('laporan')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching laporan by status: $e');
      throw Exception('Gagal memuat laporan');
    }
  }

  // Update laporan status
  Future<void> updateLaporanStatus(String id, String status) async {
    try {
      await _supabase.from('laporan').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      print('Error updating laporan status: $e');
      throw Exception('Gagal memperbarui status');
    }
  }

  // Update laporan status with admin notes
  Future<void> updateLaporanWithNotes(String id, String status, String? adminNotes) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (adminNotes != null && adminNotes.isNotEmpty) {
        updateData['admin_notes'] = adminNotes;
      }

      await _supabase.from('laporan').update(updateData).eq('id', id);
    } catch (e) {
      print('Error updating laporan with notes: $e');
      throw Exception('Gagal memperbarui laporan');
    }
  }

  // Delete laporan
  Future<void> deleteLaporan(String id) async {
    try {
      // Get image URLs first
      final laporan = await _supabase
          .from('laporan')
          .select('image_urls')
          .eq('id', id)
          .single();

      // Delete images from storage if any
      final imageUrls = laporan['image_urls'] as List<dynamic>?;
      if (imageUrls != null && imageUrls.isNotEmpty) {
        for (final url in imageUrls) {
          try {
            final uri = Uri.parse(url.toString());
            final pathSegments = uri.pathSegments;
            if (pathSegments.length >= 2) {
              final fileName =
                  '${pathSegments[pathSegments.length - 2]}/${pathSegments.last}';
              await _supabase.storage.from('laporan-images').remove([fileName]);
            }
          } catch (e) {
            print('Error deleting image: $e');
          }
        }
      }

      // Delete laporan
      await _supabase.from('laporan').delete().eq('id', id);
    } catch (e) {
      print('Error deleting laporan: $e');
      throw Exception('Gagal menghapus laporan: ${e.toString()}');
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await _supabase.from('laporan').select('status, priority');

      final stats = <String, dynamic>{
        'total': response.length,
        'baru': 0,
        'sedangDitinjau': 0,
        'sedangDikerjakan': 0,
        'selesai': 0,
        'ditolak': 0,
        'urgent': 0,
        'high': 0,
        'medium': 0,
        'low': 0,
      };

      for (final item in response) {
        final status = item['status'] as String?;
        final priority = item['priority'] as String?;

        // Count by status
        switch (status) {
          case 'Baru':
            stats['baru'] = (stats['baru'] as int) + 1;
            break;
          case 'Sedang Ditinjau':
            stats['sedangDitinjau'] = (stats['sedangDitinjau'] as int) + 1;
            break;
          case 'Sedang Dikerjakan':
            stats['sedangDikerjakan'] = (stats['sedangDikerjakan'] as int) + 1;
            break;
          case 'Selesai':
            stats['selesai'] = (stats['selesai'] as int) + 1;
            break;
          case 'Ditolak':
            stats['ditolak'] = (stats['ditolak'] as int) + 1;
            break;
        }

        // Count by priority
        switch (priority) {
          case 'Urgent':
            stats['urgent'] = (stats['urgent'] as int) + 1;
            break;
          case 'High':
            stats['high'] = (stats['high'] as int) + 1;
            break;
          case 'Medium':
            stats['medium'] = (stats['medium'] as int) + 1;
            break;
          case 'Low':
            stats['low'] = (stats['low'] as int) + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      print('Error fetching statistics: $e');
      throw Exception('Gagal memuat statistik');
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Gagal memuat data pengguna');
    }
  }

  // NEW: Get all admins
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('is_admin', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching admins: $e');
      throw Exception('Gagal memuat data admin');
    }
  }

  // NEW: Create new admin
  Future<void> createNewAdmin({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Register admin user using Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Gagal membuat akun admin');
      }

      // Create user record in users table with is_admin = true
      await _supabase.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'display_name': displayName,
        'username': email.split('@').first,
        'is_admin': true,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      });

    } on AuthException catch (e) {
      print('Auth error creating admin: ${e.message}');
      if (e.message.contains('already registered')) {
        throw Exception('Email sudah terdaftar');
      }
      throw Exception('Gagal membuat admin: ${e.message}');
    } catch (e) {
      print('Error creating admin: $e');
      throw Exception('Gagal membuat admin: ${e.toString()}');
    }
  }

  // NEW: Update admin status (activate/deactivate)
  Future<void> updateAdminStatus(String adminId, bool isActive) async {
    try {
      await _supabase
          .from('users')
          .update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', adminId);
    } catch (e) {
      print('Error updating admin status: $e');
      throw Exception('Gagal memperbarui status admin');
    }
  }

  // NEW: Remove admin role (demote to regular user)
  Future<void> removeAdminRole(String adminId) async {
    try {
      await _supabase
          .from('users')
          .update({
        'is_admin': false,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', adminId);
    } catch (e) {
      print('Error removing admin role: $e');
      throw Exception('Gagal menghapus role admin');
    }
  }

  // NEW: Promote user to admin
  Future<void> promoteToAdmin(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
        'is_admin': true,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);
    } catch (e) {
      print('Error promoting user to admin: $e');
      throw Exception('Gagal mempromosikan user ke admin');
    }
  }

  // NEW: Delete admin account
  Future<void> deleteAdmin(String adminId) async {
    try {
      // First check if this is not the last admin
      final admins = await getAllAdmins();
      if (admins.length <= 1) {
        throw Exception('Tidak dapat menghapus admin terakhir');
      }

      // Delete from users table
      await _supabase.from('users').delete().eq('id', adminId);

      // Note: Deleting from auth.users requires admin API access
      // This would need to be done via a server-side function or Supabase dashboard
    } catch (e) {
      print('Error deleting admin: $e');
      throw Exception('Gagal menghapus admin: ${e.toString()}');
    }
  }

  // Get category statistics
  Future<Map<String, int>> getCategoryStatistics() async {
    try {
      final response = await _supabase.from('laporan').select('category');

      final stats = <String, int>{};

      for (final item in response) {
        final category = item['category'] as String? ?? 'Lainnya';
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Error fetching category statistics: $e');
      throw Exception('Gagal memuat statistik kategori');
    }
  }

  // Get reports by date range
  Future<List<Map<String, dynamic>>> getReportsByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _supabase
          .from('laporan')
          .select()
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching reports by date range: $e');
      throw Exception('Gagal memuat laporan');
    }
  }

  // Stream laporan for real-time updates
  Stream<List<Map<String, dynamic>>> streamLaporan() {
    return _supabase
        .from('laporan')
        .stream(primaryKey: ['id']).order('created_at', ascending: false);
  }

  // Admin login
  Future<bool> adminLogin(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Check if user is admin using is_admin field
        final userData = await _supabase
            .from('users')
            .select('is_admin')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (userData != null && userData['is_admin'] == true) {
          return true;
        } else {
          await _supabase.auth.signOut();
          throw Exception('Akun ini bukan admin');
        }
      }
      return false;
    } catch (e) {
      print('Error admin login: $e');
      rethrow;
    }
  }

  // Admin logout
  Future<void> adminLogout() async {
    await _supabase.auth.signOut();
  }

  // Check if admin is logged in
  bool isAdminLoggedIn() {
    return _supabase.auth.currentUser != null;
  }

  // Get current admin info
  Map<String, dynamic>? getCurrentAdminInfo() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['display_name'] ?? 'Admin',
      };
    }
    return null;
  }

  // NEW: Update admin profile
  Future<void> updateAdminProfile({
    required String displayName,
    String? phone,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Admin tidak terautentikasi');
      }

      // Update auth metadata
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {'display_name': displayName},
        ),
      );

      // Update users table
      final updateData = <String, dynamic>{
        'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (phone != null) {
        updateData['phone'] = phone;
      }

      await _supabase
          .from('users')
          .update(updateData)
          .eq('id', user.id);
    } catch (e) {
      print('Error updating admin profile: $e');
      throw Exception('Gagal memperbarui profil');
    }
  }

  // NEW: Change admin password
  Future<void> changeAdminPassword({
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      print('Error changing password: $e');
      throw Exception('Gagal mengubah password');
    }
  }

  // NEW: Get admin activity logs (if you have a logs table)
  Future<List<Map<String, dynamic>>> getAdminActivityLogs({
    int limit = 50,
    String? adminId,
  }) async {
    try {
      if (adminId != null) {
        final response = await _supabase
            .from('admin_logs')
            .select()
            .eq('admin_id', adminId)
            .order('created_at', ascending: false)
            .limit(limit);
        return List<Map<String, dynamic>>.from(response);
      } else {
        final response = await _supabase
            .from('admin_logs')
            .select()
            .order('created_at', ascending: false)
            .limit(limit);
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      print('Error fetching admin logs: $e');
      // Return empty list if logs table doesn't exist
      return [];
    }
  }

  // NEW: Log admin activity
  Future<void> logAdminActivity({
    required String action,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('admin_logs').insert({
        'admin_id': user.id,
        'action': action,
        'description': description,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Silently fail if logs table doesn't exist
      print('Error logging admin activity: $e');
    }
  }
}