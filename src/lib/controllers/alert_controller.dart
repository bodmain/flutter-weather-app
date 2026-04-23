import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class AlertController extends GetxController {
  final TickerProvider vsync;

  var settings = <AlertSetting>[].obs;
  late AnimationController entryCtrl;
  final NotificationService _notificationService = NotificationService();
  
  static const String _storageKey = 'weather_alerts';

  AlertController({required this.vsync}) {
    settings.assignAll(WeatherData.alertSettings);
    
    entryCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 700),
    );
    
    _loadSettings();
    entryCtrl.forward();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedStatus = prefs.getStringList(_storageKey);
      
      if (savedStatus != null && savedStatus.length == settings.length) {
        for (int i = 0; i < settings.length; i++) {
          settings[i].isEnabled = savedStatus[i] == 'true';
        }
        settings.refresh();
      }
    } catch (e) {
      debugPrint('Error loading alert settings: $e');
    }
  }

  void toggleSetting(int index) {
    settings[index].isEnabled = !settings[index].isEnabled;
    settings.refresh();
    HapticFeedback.selectionClick();
  }

  Future<void> saveSettings() async {
    try {
      // BƯỚC 1: Yêu cầu quyền hệ thống trước khi lưu
      final bool hasPermission = await _notificationService.requestPermissions();
      
      if (!hasPermission) {
        Get.snackbar(
          'Quyền truy cập', 
          'Vui lòng cấp quyền thông báo trong Cài đặt để sử dụng tính năng này.',
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }

      // BƯỚC 2: Lưu vào bộ nhớ máy
      final prefs = await SharedPreferences.getInstance();
      final statusList = settings.map((s) => s.isEnabled.toString()).toList();
      await prefs.setStringList(_storageKey, statusList);
      
      final onCount = settings.where((s) => s.isEnabled).length;
      HapticFeedback.mediumImpact();

      // BƯỚC 3: Lập lịch thông báo
      if (settings.length > 3) {
        if (settings[3].isEnabled) {
          await _notificationService.scheduleDailyGreeting();
        } else {
          await _notificationService.cancelDailyGreeting();
        }
      }

      // Thông báo thành công
      await _notificationService.showNotification(
        id: 0,
        title: 'Cài đặt thành công',
        body: 'Hệ thống đã ghi nhận các thay đổi của bạn.',
      );
      
      Get.closeAllSnackbars();
      Get.snackbar(
        'Thành công',
        'Đã lưu cài đặt và kích hoạt thông báo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.accent.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 20,
        icon: const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white),
      );
    } catch (e) {
      // Fallback nếu vẫn lỗi do hệ điều hành chặn Exact Alarm
      Get.snackbar('Thông báo', 'Cài đặt đã lưu (Chế độ tối ưu pin)');
      debugPrint('Notification schedule error: $e');
    }
  }

  @override
  void onClose() {
    entryCtrl.dispose();
    super.onClose();
  }
}
