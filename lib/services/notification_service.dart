import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/notifications_page.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _supabase = Supabase.instance.client;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  final _notificationsController = StreamController<List<NotificationItem>>.broadcast();
  Stream<List<NotificationItem>> get notificationsStream => _notificationsController.stream;

  List<NotificationItem> _notifications = [];
  RealtimeChannel? _subscription;

  bool _isSoundEnabled = true;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  Future<void> initialize() async {
    // 1. Load initial notifications from recent reports
    await _loadInitialData();

    // 2. Subscribe to realtime inserts on laporan table
    _subscription = _supabase
        .channel('public:laporan')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'laporan',
          callback: (payload) {
            _handleNewReport(payload.newRecord);
          },
        )
        .subscribe();
  }

  Future<void> _loadInitialData() async {
    try {
      final response = await _supabase
          .from('laporan')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      final List<NotificationItem> loadedItems = [];
      
      for (var record in response) {
        // Build a notification item for each recent report
        loadedItems.add(
          NotificationItem(
            id: record['id'].toString(),
            title: 'Laporan Baru: ${record['category'] ?? 'Lainnya'}',
            message: record['description'] ?? 'Detail laporan tidak tersedia.',
            type: NotificationType.report,
            createdAt: DateTime.parse(record['created_at']),
            isRead: true, // Mark initial/old ones as read by default
            icon: _getIconForCategory(record['category']),
            priority: _getPriorityForStatus(record['priority']),
            rawData: record,
          ),
        );
      }

      _notifications = loadedItems;
      _notificationsController.add(_notifications);
    } catch (e) {
      print('Error loading initial notifications: $e');
    }
  }

  void _handleNewReport(Map<String, dynamic> record) {
    final newItem = NotificationItem(
      id: record['id'].toString(),
      title: 'Laporan Baru Masuk',
      message: record['description'] ?? 'Ada laporan infrastruktur baru.',
      type: NotificationType.report,
      createdAt: DateTime.parse(record['created_at']),
      isRead: false, // New notifications are unread
      icon: _getIconForCategory(record['category']),
      priority: _getPriorityForStatus(record['priority']),
      rawData: record,
    );

    // Add to top of list
    _notifications = [newItem, ..._notifications];
    
    // Play sound if enabled
    if (_isSoundEnabled) {
      _playSound();
    }

    // Broadcast update
    _notificationsController.add(_notifications);
  }

  Future<void> _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification_sound.mp3'));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  // Get current raw list
  List<NotificationItem> get currentNotifications => _notifications;

  // Unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationsController.add(_notifications);
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _notificationsController.add(_notifications);
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _notificationsController.add(_notifications);
  }

  void clearAll() {
    _notifications.clear();
    _notificationsController.add(_notifications);
  }

  void dispose() {
    _subscription?.unsubscribe();
    _notificationsController.close();
    _audioPlayer.dispose();
  }

  // Helper mappings

  static IconData _getIconForCategory(String? category) {
    if (category == null) return Icons.assignment_rounded;
    final cat = category.toLowerCase();
    if (cat.contains('jalan')) return Icons.add_road_rounded;
    if (cat.contains('air') || cat.contains('sungai')) return Icons.water_drop_rounded;
    if (cat.contains('lampu') || cat.contains('listrik')) return Icons.lightbulb_rounded;
    if (cat.contains('sampah') || cat.contains('kebersihan')) return Icons.delete_outline_rounded;
    return Icons.assignment_rounded;
  }

  static NotificationPriority _getPriorityForStatus(String? priorityStr) {
    if (priorityStr == null) return NotificationPriority.normal;
    final p = priorityStr.toLowerCase();
    if (p == 'urgent') return NotificationPriority.urgent;
    if (p == 'high') return NotificationPriority.high;
    if (p == 'low') return NotificationPriority.low;
    return NotificationPriority.normal;
  }
}
