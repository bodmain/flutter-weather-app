// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
 import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../models/weather_model.dart';
import '../widgets/glass_card.dart';
import '../controllers/search_controller.dart' as ctrl;

class SearchScreen extends StatefulWidget {
  final Function(WeatherInfo) onCitySelected;
  final bool isNight;
  const SearchScreen({super.key, required this.onCitySelected, required this.isNight});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late ctrl.SearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ctrl.SearchController(
      vsync: this,
      onCitySelected: widget.onCitySelected,
    );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildLabel(),
              Expanded(child: _buildList()),
            ],
          ),
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
          Text('Tìm kiếm', 
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: titleColor, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Nhập tên thành phố để xem thời tiết',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subTitleColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isNight = widget.isNight;
    final textColor = isNight ? AppColors.text1 : AppColors.bg0;
    final hintColor = isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        controller: _controller.textCtrl,
        focusNode: _controller.focusNode,
        onChanged: _controller.onTextChanged,
        style: GoogleFonts.nunito(
          color: textColor, fontSize: 15, fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isNight ? AppColors.glass : Colors.white.withValues(alpha: 0.4),
          hintText: 'Nhập tên thành phố (ví dụ: Tokyo, Paris...)',
          hintStyle: GoogleFonts.nunito(color: hintColor, fontWeight: FontWeight.w500),
          prefixIcon: Obx(() => _controller.isSearching.value 
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CupertinoActivityIndicator(radius: 8),
              )
            : Icon(CupertinoIcons.search, 
                color: isNight ? AppColors.accent : AppColors.bg0.withValues(alpha: 0.6), size: 22)),
          suffixIcon: GestureDetector(
            onTap: () {
              _controller.clearSearch();
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.3), 
                shape: BoxShape.circle
              ),
              child: Icon(CupertinoIcons.xmark, size: 13, color: isNight ? AppColors.bg0 : Colors.white),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: isNight ? AppColors.glassBorder : AppColors.bg0.withValues(alpha: 0.15),
              width: 1
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: isNight ? AppColors.glassBorder : AppColors.bg0.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: isNight ? AppColors.accent : AppColors.bg0.withValues(alpha: 0.4),
              width: 1.5
            ),
          ),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildLabel() {
    return Obx(() {
      final label = _controller.textCtrl.text.isNotEmpty
          ? (_controller.results.isEmpty ? 'Không tìm thấy' : 'Kết quả (${_controller.results.length})')
          : (ctrl.SearchController.history.isNotEmpty ? 'Tìm kiếm gần đây' : 'Thành phố gợi ý');
      
      final labelColor = widget.isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.6);

      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: 10, fontWeight: FontWeight.w800,
            color: labelColor,
            letterSpacing: 1.5,
          ),
        ),
      );
    });
  }

  Widget _buildList() {
    return Obx(() {
      if (_controller.results.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.globe, size: 64, color: widget.isNight ? AppColors.text3 : AppColors.bg0.withValues(alpha: 0.3)),
              const SizedBox(height: 14),
              Text('Không tìm thấy thành phố', 
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: widget.isNight ? AppColors.text1 : AppColors.bg0,
                  fontWeight: FontWeight.w600
                )),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _controller.results.length,
        itemBuilder: (ctx, i) {
          final delay = (i * 0.06).clamp(0.0, 0.5);
          final itemAnim = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _controller.listCtrl,
              curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
            ),
          );
          return FadeTransition(
            opacity: itemAnim,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
                CurvedAnimation(parent: _controller.listCtrl, curve: Interval(delay, delay + 0.4, curve: Curves.easeOutCubic)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _tile(_controller.results[i]),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _tile(WeatherInfo city) {
    final isNight = widget.isNight;
    final textColor = isNight ? AppColors.text1 : AppColors.bg0;
    final subColor = isNight ? AppColors.text2 : AppColors.bg0.withValues(alpha: 0.6);

    return GlassCard(
      decoration: isNight ? AppTheme.glassBox() : _dayNormalBox(),
      onTap: () => _controller.selectCity(city),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(children: [
        Hero(
          tag: 'weather-icon-${city.cityName}',
          child: SizedBox(
            width: 44, 
            child: Icon(city.condition.icon, size: 32, color: city.condition.color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(city.cityName, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: textColor), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text('${city.country}  ·  ${city.condition.label}', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: subColor)),
          ],
        )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${city.temperature.toInt()}°', 
              style: GoogleFonts.outfit(
                fontSize: 22, fontWeight: FontWeight.w500, 
                color: textColor, 
                letterSpacing: -0.5
              )),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${city.humidity}%', 
                  style: GoogleFonts.nunito(fontSize: 10, color: subColor, fontWeight: FontWeight.w800)),
                const SizedBox(width: 4),
                Icon(CupertinoIcons.drop_fill, size: 10, color: AppColors.rain),
              ],
            ),
          ],
        ),
      ]),
    );
  }

  BoxDecoration _dayNormalBox() => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.4),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
  );
}
