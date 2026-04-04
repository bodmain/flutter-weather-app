import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

class AlertController {
  final TickerProvider vsync;
  final BuildContext context;

  late List<AlertSetting> settings;
  late AnimationController entryCtrl;

  AlertController({required this.vsync, required this.context}) {
    settings = WeatherData.alertSettings;
    entryCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 700),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) => entryCtrl.forward());
  }

  void toggleSetting(int index, VoidCallback onUpdate) {
    settings[index].isEnabled = !settings[index].isEnabled;
    HapticFeedback.selectionClick();
    onUpdate();
  }

  void saveSettings() {
    final onCount = settings.where((s) => s.isEnabled).length;
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅  Đã lưu $onCount thông báo đang bật',
        style: GoogleFonts.nunito(
          color: AppColors.text1, fontWeight: FontWeight.w700,
        ),
      ),
      // Sửa lỗi: Sử dụng bg1 vì bg2 không tồn tại trong AppColors
      backgroundColor: AppColors.bg1,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    ));
  }

  void dispose() {
    entryCtrl.dispose();
  }
}
