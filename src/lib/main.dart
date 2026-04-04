// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/alert_screen.dart';
import 'theme/app_theme.dart';
import 'models/weather_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _idx = 0;
  late AnimationController _navAnim;
  WeatherInfo _selectedWeather = WeatherData.hanoi;

  @override
  void initState() {
    super.initState();
    _navAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..value = 1;
    _updateSystemUI();
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _selectedWeather.isNight ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: _selectedWeather.isNight ? AppColors.bg0 : AppColors.dayBg1,
      systemNavigationBarIconBrightness: _selectedWeather.isNight ? Brightness.light : Brightness.dark,
    ));
  }

  void _onTap(int index) {
    if (index == _idx) return;
    HapticFeedback.selectionClick();
    setState(() => _idx = index);
    _navAnim.forward(from: 0);
  }

  void _updateCity(WeatherInfo city) {
    setState(() {
      _selectedWeather = city;
      _idx = 0; 
    });
    _updateSystemUI();
    _navAnim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isNight = _selectedWeather.isNight;
    
    final screens = [
      HomeScreen(weather: _selectedWeather), 
      SearchScreen(onCitySelected: _updateCity, isNight: isNight), 
      AlertScreen(isNight: isNight)
    ];

    return Scaffold(
      backgroundColor: isNight ? AppColors.bg0 : AppColors.dayBg0,
      extendBody: true,
      body: IndexedStack(
        index: _idx,
        children: screens,
      ),
      bottomNavigationBar: _buildNav(isNight),
    );
  }

  Widget _buildNav(bool isNight) {
    final labels = ['Trang chủ', 'Tìm kiếm', 'Thông báo'];
    final icons = [
      (CupertinoIcons.house, CupertinoIcons.house_fill),
      (CupertinoIcons.search, CupertinoIcons.search),
      (CupertinoIcons.bell, CupertinoIcons.bell_fill),
    ];

    return ClipRRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: (isNight ? AppColors.bg0 : Colors.white).withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(color: isNight ? AppColors.glassBorder : Colors.black12, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: List.generate(3, (i) => Expanded(
                child: _NavItem(
                  icon: icons[i].$1,
                  activeIcon: icons[i].$2,
                  label: labels[i],
                  isActive: _idx == i,
                  isNight: isNight,
                  onTap: () => _onTap(i),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final bool isNight;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.isNight,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isNight ? AppColors.accent : Colors.blue.shade800;
    final inactiveColor = widget.isNight ? AppColors.text3 : Colors.black38;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isActive ? widget.activeIcon : widget.icon,
              color: widget.isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w600,
                color: widget.isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
