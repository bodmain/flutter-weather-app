// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/alert_screen.dart';
import 'theme/app_theme.dart';
import 'models/weather_model.dart';
import 'controllers/weather_controller.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Notification Service
  final notificationService = NotificationService();
  await notificationService.init();
  
  Get.put(WeatherController());
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
  final WeatherController _weatherCtrl = Get.find<WeatherController>();

  @override
  void initState() {
    super.initState();
    _updateSystemUI();
  }

  void _updateSystemUI() {
    final isNight = _weatherCtrl.weather.value?.isNight ?? true;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isNight ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isNight ? AppColors.bg0 : AppColors.dayBg1,
      systemNavigationBarIconBrightness: isNight ? Brightness.light : Brightness.dark,
    ));
  }

  void _onTap(int index) {
    if (index == _idx) return;
    HapticFeedback.selectionClick();
    setState(() => _idx = index);
  }

  void _updateCity(WeatherInfo city) {
    _weatherCtrl.fetchCurrentWeather(city.cityName);
    setState(() => _idx = 0);
    _updateSystemUI();
  }

  @override
  Widget build(BuildContext context) {
    final isNight = _weatherCtrl.weather.value?.isNight ?? true;
    
    final screens = [
      HomeScreen(weather: _weatherCtrl.weather.value ?? WeatherData.hanoi), 
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
      bottomNavigationBar: Obx(() => _buildNav(_weatherCtrl.weather.value?.isNight ?? true)),
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
          border: Border(top: BorderSide(color: isNight ? AppColors.glassBorder : Colors.black12, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: List.generate(3, (i) => Expanded(
                child: InkWell(
                  onTap: () => _onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _idx == i ? icons[i].$2 : icons[i].$1,
                        color: _idx == i 
                            ? (isNight ? AppColors.accent : Colors.blue.shade800) 
                            : (isNight ? AppColors.text3 : Colors.black38),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: _idx == i ? FontWeight.w800 : FontWeight.w600,
                          color: _idx == i 
                              ? (isNight ? AppColors.accent : Colors.blue.shade800) 
                              : (isNight ? AppColors.text3 : Colors.black38),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
