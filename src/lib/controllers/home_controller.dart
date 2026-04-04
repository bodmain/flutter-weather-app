import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/weather_model.dart';

class HomeController {
  final TickerProvider vsync;
  final WeatherInfo weather;
  
  // Logic Clock
  late DateTime now;
  Timer? clockTimer;
  final StreamController<DateTime> _timeStream = StreamController<DateTime>.broadcast();
  Stream<DateTime> get timeStream => _timeStream.stream;

  // Animation Logic
  late AnimationController entryCtrl;
  late List<Animation<double>> fadeIns;
  late List<Animation<Offset>> slideIns;

  HomeController({required this.vsync, required this.weather}) {
    now = DateTime.now();
    _initClock();
    _initAnimations();
  }

  void _initClock() {
    clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      now = DateTime.now();
      _timeStream.add(now);
    });
  }

  void _initAnimations() {
    entryCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 900),
    );

    fadeIns = List.generate(6, (i) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(i * 0.1, i * 0.1 + 0.4, curve: Curves.easeOut),
      ),
    ));

    slideIns = List.generate(6, (i) =>
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: entryCtrl,
            curve: Interval(i * 0.1, i * 0.1 + 0.4, curve: Curves.easeOutCubic),
          ),
        ));
    
    entryCtrl.forward();
  }

  // Logic Reload (giả lập)
  Future<void> refreshWeather() async {
    HapticFeedback.lightImpact();
    // Giả lập delay mạng
    await Future.delayed(const Duration(seconds: 2));
    
    // Reset animation để tạo hiệu ứng dữ liệu mới đổ về
    entryCtrl.forward(from: 0);
  }

  String getFormattedDate(DateTime dt) {
    const days = ['Chủ Nhật','Thứ Hai','Thứ Ba','Thứ Tư','Thứ Năm','Thứ Sáu','Thứ Bảy'];
    return '${days[dt.weekday % 7]}, '
        '${dt.day.toString().padLeft(2,'0')}/'
        '${dt.month.toString().padLeft(2,'0')}/${dt.year}'
        '  ·  '
        '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  void dispose() {
    clockTimer?.cancel();
    entryCtrl.dispose();
    _timeStream.close();
  }
}
