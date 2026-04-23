// lib/screens/alert_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/weather_model.dart';
import '../widgets/glass_card.dart';
import '../controllers/alert_controller.dart' as ctrl;

class AlertScreen extends StatefulWidget {
  final bool isNight;
  const AlertScreen({super.key, required this.isNight});
  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> with SingleTickerProviderStateMixin {
  late ctrl.AlertController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ctrl.AlertController(vsync: this);
  }

  @override
  void dispose() {
    _controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getScreenGradient(widget.isNight)),
        child: SafeArea(
          child: Obx(() {
            final weatherAlerts = _controller.settings.sublist(0, 3);
            final generalAlerts = _controller.settings.sublist(3);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                
                // Đã loại bỏ _buildActiveBanner() ở đây
                
                SliverToBoxAdapter(child: _buildSectionLabel('CẢNH BÁO THỜI TIẾT')),
                SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => _animatedRow(weatherAlerts[i], i, i),
                  childCount: weatherAlerts.length,
                )),
                
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverToBoxAdapter(child: _buildSectionLabel('THÔNG BÁO CHUNG')),
                SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => _animatedRow(generalAlerts[i], i + 3, i + 3),
                  childCount: generalAlerts.length,
                )),
                
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
                SliverToBoxAdapter(child: _buildSaveButton()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titleColor = widget.isNight ? AppColors.text1 : AppColors.bg0;
    final subTitleColor = widget.isNight ? AppColors.text2 : AppColors.bg0.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông báo', 
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: titleColor, fontWeight: FontWeight.w800
            )),
          const SizedBox(height: 4),
          Text('Tùy chỉnh cảnh báo thời tiết của bạn', 
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subTitleColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    final labelColor = widget.isNight ? AppColors.accent : AppColors.bg0.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      child: Text(label, 
        style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: labelColor, letterSpacing: 1.5)),
    );
  }

  Widget _animatedRow(AlertSetting s, int index, int animIdx) {
    final delay = (animIdx * 0.08).clamp(0.0, 0.5);
    final anim = CurvedAnimation(parent: _controller.entryCtrl, curve: Interval(delay, delay + 0.35, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
        child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: _buildToggleRow(s, index)),
      ),
    );
  }

  Widget _buildToggleRow(AlertSetting s, int index) {
    final isNight = widget.isNight;
    final titleColor = isNight ? AppColors.text1 : AppColors.bg0;
    final descColor = isNight ? AppColors.text2 : AppColors.bg0.withValues(alpha: 0.6);
    final iconColor = s.isEnabled ? AppColors.accent : (isNight ? AppColors.text3 : Colors.grey);

    return GlassCard(
      decoration: s.isEnabled 
        ? (isNight ? AppTheme.glassBoxHighlight() : _dayHighlightBox()) 
        : (isNight ? AppTheme.glassBox() : _dayNormalBox()),
      onTap: () => _controller.toggleSetting(index),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(children: [
        SizedBox(
          width: 40, 
          child: Icon(s.icon, color: iconColor, size: 26)
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: titleColor)),
          Text(s.description, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w500, color: descColor)),
        ])),
        _buildCustomToggle(s.isEnabled, index),
      ]),
    );
  }

  Widget _buildCustomToggle(bool value, int index) {
    return GestureDetector(
      onTap: () => _controller.toggleSetting(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46, height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: value ? AppColors.accent : (widget.isNight ? AppColors.glassBorder : AppColors.bg0.withValues(alpha: 0.1)),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(margin: const EdgeInsets.all(3), width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)])),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TapScale(
        onTap: _controller.saveSettings,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.isNight 
              ? [AppColors.accent, const Color(0xFF2563EB)]
              : [AppColors.bg0, const Color(0xFF1A237E)]),
            borderRadius: AppTheme.buttonRadius,
            boxShadow: [
              BoxShadow(
                color: (widget.isNight ? AppColors.accent : AppColors.bg0).withValues(alpha: 0.3),
                blurRadius: 12, offset: const Offset(0, 4)
              )
            ]
          ),
          child: Text('Lưu cài đặt', textAlign: TextAlign.center, style: GoogleFonts.nunito(
            fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white
          )),
        ),
      ),
    );
  }

  BoxDecoration _dayNormalBox() => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.35),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
  );

  BoxDecoration _dayHighlightBox() => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.8),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1.5),
    boxShadow: [
      BoxShadow(color: Colors.blue.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
    ]
  );
}
