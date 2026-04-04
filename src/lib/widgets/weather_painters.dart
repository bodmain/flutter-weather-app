// lib/widgets/weather_painters.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/weather_model.dart';

class WeatherAnimation extends StatefulWidget {
  final WeatherCondition condition;
  final double size;
  const WeatherAnimation({super.key, required this.condition, this.size = 200});

  @override
  State<WeatherAnimation> createState() => _WeatherAnimationState();
}

class _WeatherAnimationState extends State<WeatherAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _painterFor(widget.condition, _ctrl.value),
        ),
      ),
    );
  }

  CustomPainter _painterFor(WeatherCondition c, double t) {
    switch (c) {
      case WeatherCondition.sunny: return _SunPainter(t);
      case WeatherCondition.partlyCloudy: return _PartlyCloudyPainter(t);
      case WeatherCondition.cloudy: return _CloudPainter(t, color: Colors.white70);
      case WeatherCondition.lightRain: return _RainPainter(t, heavy: false);
      case WeatherCondition.heavyRain: return _RainPainter(t, heavy: true);
      case WeatherCondition.thunderstorm: return _ThunderPainter(t);
      case WeatherCondition.fog: return _CloudPainter(t, color: Colors.white30, isFog: true);
      case WeatherCondition.clearNight:
      case WeatherCondition.night:
        return _NightPainter(t);
      default: return _SunPainter(t);
    }
  }
}

// ☀️ Nắng
class _SunPainter extends CustomPainter {
  final double t;
  _SunPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * (1.2 + i * 0.4), Paint()
        ..color = AppColors.warm.withValues(alpha: 0.1 / i)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * i.toDouble()));
    }
    final rayPaint = Paint()..color = AppColors.warm.withValues(alpha: 0.4)..strokeWidth = 4..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final angle = (t * math.pi * 2) + (i * math.pi * 2 / 12);
      final start = center + Offset.fromDirection(angle, radius + 10);
      final end = center + Offset.fromDirection(angle, radius + 30 + (math.sin(t * 10 + i) * 5));
      canvas.drawLine(start, end, rayPaint);
    }
    canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(
      colors: [const Color(0xFFFFE082), AppColors.warm, const Color(0xFFE65100)],
      stops: const [0.2, 0.8, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius)));
  }
  @override
  bool shouldRepaint(_SunPainter old) => true;
}

// 🌙 Ban đêm (Mặt trăng)
class _NightPainter extends CustomPainter {
  final double t;
  _NightPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.22;

    // Glow
    canvas.drawCircle(center, radius * 1.5, Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));

    // Moon
    final moonPaint = Paint()..color = const Color(0xFFE0E0E0);
    canvas.drawCircle(center, radius, moonPaint);

    // Crescent cutout
    canvas.drawCircle(center + Offset(radius * 0.4, -radius * 0.2), radius * 0.9, Paint()
      ..color = Colors.black // Sẽ được clip hoặc dùng blend mode trong thực tế, ở đây giả lập cutout
      ..blendMode = BlendMode.dstOut);
    
    // Stars
    final rng = math.Random(42);
    for(int i=0; i<10; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final opacity = (math.sin(t * 5 + i) + 1) / 2;
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = Colors.white.withValues(alpha: opacity));
    }
  }
  @override
  bool shouldRepaint(_NightPainter old) => true;
}

// 🌧️ Mưa
class _RainPainter extends CustomPainter {
  final double t;
  final bool heavy;
  final math.Random rng = math.Random(42);
  _RainPainter(this.t, {this.heavy = false});
  @override
  void paint(Canvas canvas, Size size) {
    final count = heavy ? 30 : 15;
    final rainPaint = Paint()..color = AppColors.rain.withValues(alpha: 0.6)..strokeWidth = heavy ? 2.5 : 1.5..strokeCap = StrokeCap.round;
    for (int i = 0; i < count; i++) {
      final x = (rng.nextDouble() * size.width);
      final speed = 1.0 + (i % 5) * 0.2;
      final dropT = (t * speed + (i / count)) % 1.0;
      final y1 = size.height * 0.3 + (dropT * size.height * 0.7);
      final y2 = y1 + (heavy ? 20 : 12);
      canvas.drawLine(Offset(x, y1), Offset(x - 3, y2), rainPaint);
    }
    _drawCloud(canvas, Offset(size.width * 0.5, size.height * 0.3), size.width * 0.7, Colors.white.withValues(alpha: 0.9));
  }
  void _drawCloud(Canvas canvas, Offset center, double w, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(center, w * 0.3, p);
    canvas.drawCircle(center + Offset(-w * 0.2, w * 0.05), w * 0.25, p);
    canvas.drawCircle(center + Offset(w * 0.25, w * 0.05), w * 0.2, p);
  }
  @override
  bool shouldRepaint(_RainPainter old) => true;
}

// ⚡ Sấm sét
class _ThunderPainter extends CustomPainter {
  final double t;
  _ThunderPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final flash = math.sin(t * 40).abs();
    if (flash > 0.85) {
      final boltPath = Path()..moveTo(size.width * 0.5, size.height * 0.3)..lineTo(size.width * 0.4, size.height * 0.5)..lineTo(size.width * 0.55, size.height * 0.5)..lineTo(size.width * 0.35, size.height * 0.8);
      canvas.drawPath(boltPath, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.drawPath(boltPath, Paint()..color = Colors.yellowAccent..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    _drawCloud(canvas, Offset(size.width * 0.5, size.height * 0.3), size.width * 0.7, const Color(0xFF455A64));
  }
  void _drawCloud(Canvas canvas, Offset center, double w, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(center, w * 0.3, p);
    canvas.drawCircle(center + Offset(-w * 0.2, w * 0.05), w * 0.25, p);
    canvas.drawCircle(center + Offset(w * 0.25, w * 0.05), w * 0.2, p);
  }
  @override
  bool shouldRepaint(_ThunderPainter old) => true;
}

// ☁️ Mây
class _CloudPainter extends CustomPainter {
  final double t;
  final Color color;
  final bool isFog;
  _CloudPainter(this.t, {required this.color, this.isFog = false});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5 + math.sin(t * math.pi * 2) * 10, size.height * 0.5);
    final w = size.width * 0.7;
    final p = Paint()..color = color;
    if (isFog) p.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, w * 0.3, p);
    canvas.drawCircle(center + Offset(-w * 0.2, w * 0.05), w * 0.25, p);
    canvas.drawCircle(center + Offset(w * 0.25, w * 0.05), w * 0.2, p);
  }
  @override
  bool shouldRepaint(_CloudPainter old) => true;
}

class _PartlyCloudyPainter extends CustomPainter {
  final double t;
  _PartlyCloudyPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    _SunPainter(t).paint(canvas, size * 0.8);
    _CloudPainter(t, color: Colors.white).paint(canvas, size);
  }
  @override
  bool shouldRepaint(_PartlyCloudyPainter old) => true;
}
