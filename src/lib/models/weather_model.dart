// lib/models/weather_model.dart
import 'package:flutter/cupertino.dart';

enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  lightRain,
  heavyRain,
  thunderstorm,
  fog,
  night,
  clearNight,
}

extension WeatherConditionX on WeatherCondition {
  IconData get icon {
    switch (this) {
      case WeatherCondition.sunny:        return CupertinoIcons.sun_max_fill;
      case WeatherCondition.partlyCloudy: return CupertinoIcons.cloud_sun_fill;
      case WeatherCondition.cloudy:       return CupertinoIcons.cloud_fill;
      case WeatherCondition.lightRain:    return CupertinoIcons.cloud_rain_fill;
      case WeatherCondition.heavyRain:    return CupertinoIcons.cloud_heavyrain_fill;
      case WeatherCondition.thunderstorm: return CupertinoIcons.cloud_bolt_rain_fill;
      case WeatherCondition.fog:          return CupertinoIcons.cloud_fog_fill;
      case WeatherCondition.night:        return CupertinoIcons.cloud_moon_fill;
      case WeatherCondition.clearNight:   return CupertinoIcons.moon_stars_fill;
    }
  }

  Color get color {
    switch (this) {
      case WeatherCondition.sunny:        return const Color(0xFFFFBD59);
      case WeatherCondition.partlyCloudy: return const Color(0xFFFFD54F);
      case WeatherCondition.cloudy:       return const Color(0xFFB0BEC5);
      case WeatherCondition.lightRain:    return const Color(0xFF64B5F6);
      case WeatherCondition.heavyRain:    return const Color(0xFF2196F3);
      case WeatherCondition.thunderstorm: return const Color(0xFF9575CD);
      case WeatherCondition.fog:          return const Color(0xFFCFD8DC);
      case WeatherCondition.night:
      case WeatherCondition.clearNight:   return const Color(0xFF81D4FA);
    }
  }

  String get label {
    switch (this) {
      case WeatherCondition.sunny:        return 'Nắng đẹp';
      case WeatherCondition.partlyCloudy: return 'Ít mây';
      case WeatherCondition.cloudy:       return 'Nhiều mây';
      case WeatherCondition.lightRain:    return 'Mưa nhỏ';
      case WeatherCondition.heavyRain:    return 'Mưa lớn';
      case WeatherCondition.thunderstorm: return 'Dông bão';
      case WeatherCondition.fog:          return 'Sương mù';
      case WeatherCondition.night:        return 'Ban đêm';
      case WeatherCondition.clearNight:   return 'Trời quang';
    }
  }
}

class WeatherInfo {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int uvIndex;
  final String description;
  final WeatherCondition condition;
  final bool isNight;

  const WeatherInfo({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.description,
    required this.condition,
    this.isNight = false,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];
    final sys = json['sys'];
    final wind = json['wind'];
    final dt = json['dt'] as int;
    final sunrise = sys['sunrise'] as int;
    final sunset = sys['sunset'] as int;

    return WeatherInfo(
      cityName: json['name'],
      country: sys['country'],
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      uvIndex: 0, // OpenWeather 2.5 free basic doesn't have UV
      description: weather['description'],
      condition: _mapMainToCondition(weather['main'], weather['id']),
      isNight: dt < sunrise || dt >= sunset,
    );
  }

  static WeatherCondition _mapMainToCondition(String main, int id) {
    if (id >= 200 && id < 300) return WeatherCondition.thunderstorm;
    if (id >= 300 && id < 600) return WeatherCondition.heavyRain;
    if (id >= 600 && id < 700) return WeatherCondition.lightRain;
    if (id >= 700 && id < 800) return WeatherCondition.fog;
    if (id == 800) return WeatherCondition.sunny;
    if (id == 801) return WeatherCondition.partlyCloudy;
    return WeatherCondition.cloudy;
  }

  // 🧠 Logic Lời khuyên thông minh
  List<(IconData, String, Color)> get smartTips {
    final List<(IconData, String, Color)> tips = [];

    if (temperature >= 32) {
      tips.add((CupertinoIcons.drop_fill, "Trời khá nóng, hãy uống đủ nước và hạn chế ra ngoài lâu.", const Color(0xFF64B5F6)));
    } else if (temperature <= 18) {
      tips.add((CupertinoIcons.snow, "Trời lạnh rồi, nhớ mặc áo ấm để bảo vệ sức khỏe bạn nhé.", const Color(0xFF81D4FA)));
    }

    if (condition == WeatherCondition.heavyRain || condition == WeatherCondition.thunderstorm) {
      tips.add((CupertinoIcons.umbrella_fill, "Đang có mưa lớn, bạn nên hạn chế di chuyển ngoài đường.", const Color(0xFFEF5350)));
    } else if (condition == WeatherCondition.lightRain) {
      tips.add((CupertinoIcons.umbrella, "Trời có mưa nhỏ, đừng quên mang theo ô khi ra ngoài.", const Color(0xFF90CAF9)));
    }

    if (tips.isEmpty) {
      tips.add((CupertinoIcons.heart_fill, "Thời tiết hôm nay rất tuyệt, chúc bạn một ngày tốt lành!", const Color(0xFF81C784)));
    }

    return tips;
  }
}

class HourlyForecast {
  final String time;
  final double temperature;
  final int rainChance;
  final WeatherCondition condition;
  final bool isNow;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.rainChance,
    required this.condition,
    this.isNow = false,
  });
}

class DailyForecast {
  final String day;
  final double tempMin;
  final double tempMax;
  final WeatherCondition condition;

  const DailyForecast({
    required this.day,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
  });
}

class AlertSetting {
  final String title;
  final String description;
  final IconData icon;
  bool isEnabled;

  AlertSetting({
    required this.title,
    required this.description,
    required this.icon,
    required this.isEnabled,
  });
}

class WeatherData {
  static const WeatherInfo hanoi = WeatherInfo(
    cityName: 'Hà Nội',
    country: 'Việt Nam',
    temperature: 28,
    feelsLike: 30,
    tempMin: 22,
    tempMax: 31,
    humidity: 72,
    windSpeed: 12,
    uvIndex: 6,
    description: 'Nắng nhẹ',
    condition: WeatherCondition.sunny,
    isNight: false,
  );

  static const List<WeatherInfo> cities = [
    WeatherInfo(cityName: 'Hà Nội',      country: 'Việt Nam', temperature: 28, feelsLike: 30, tempMin: 22, tempMax: 31, humidity: 72, windSpeed: 12, uvIndex: 6, description: 'Nắng nhẹ',  condition: WeatherCondition.partlyCloudy, isNight: false),
    WeatherInfo(cityName: 'Hồ Chí Minh', country: 'Việt Nam', temperature: 24, feelsLike: 26, tempMin: 22, tempMax: 28, humidity: 85, windSpeed: 5,  uvIndex: 0, description: 'Trời quang', condition: WeatherCondition.clearNight, isNight: true),
    WeatherInfo(cityName: 'Đà Nẵng',     country: 'Việt Nam', temperature: 29, feelsLike: 31, tempMin: 24, tempMax: 32, humidity: 68, windSpeed: 15, uvIndex: 5, description: 'Ít mây',    condition: WeatherCondition.cloudy, isNight: false),
    WeatherInfo(cityName: 'Đà Lạt',      country: 'Việt Nam', temperature: 16, feelsLike: 14, tempMin: 12, tempMax: 18, humidity: 90, windSpeed: 10, uvIndex: 0, description: 'Đêm lạnh',  condition: WeatherCondition.clearNight, isNight: true),
  ];

  static const List<HourlyForecast> hourlyForecasts = [
    HourlyForecast(time: 'Bây giờ', temperature: 28, rainChance: 0,  condition: WeatherCondition.sunny,        isNow: true),
    HourlyForecast(time: '15:00',   temperature: 27, rainChance: 5,  condition: WeatherCondition.partlyCloudy),
    HourlyForecast(time: '20:00',   temperature: 22, rainChance: 55, condition: WeatherCondition.clearNight),
  ];

  static const List<DailyForecast> dailyForecasts = [
    DailyForecast(day: 'Thứ Hai',  tempMin: 22, tempMax: 31, condition: WeatherCondition.sunny),
    DailyForecast(day: 'Thứ Ba',   tempMin: 23, tempMax: 32, condition: WeatherCondition.partlyCloudy),
    DailyForecast(day: 'Thứ Tư',   tempMin: 24, tempMax: 30, condition: WeatherCondition.cloudy),
    DailyForecast(day: 'Thứ Năm',  tempMin: 21, tempMax: 28, condition: WeatherCondition.lightRain),
    DailyForecast(day: 'Thứ Sáu',  tempMin: 20, tempMax: 27, condition: WeatherCondition.heavyRain),
    DailyForecast(day: 'Thứ Bảy',  tempMin: 22, tempMax: 29, condition: WeatherCondition.thunderstorm),
    DailyForecast(day: 'Chủ Nhật', tempMin: 23, tempMax: 30, condition: WeatherCondition.sunny),
  ];

  static List<AlertSetting> get alertSettings => [
    AlertSetting(title: 'Cảnh báo mưa',              description: 'Thông báo khi có mưa lớn sắp xảy ra',         icon: CupertinoIcons.cloud_rain_fill, isEnabled: true),
    AlertSetting(title: 'Cảnh báo UV cao',            description: 'Chỉ số UV > 6, nguy hiểm cho làn da',         icon: CupertinoIcons.sun_max_fill,  isEnabled: true),
    AlertSetting(title: 'Cảnh báo bão',               description: 'Cập nhật bão & áp thấp nhiệt đới',            icon: CupertinoIcons.hurricane, isEnabled: false),
    AlertSetting(title: 'Dự báo hằng ngày',           description: 'Nhận tóm tắt thời tiết lúc 7:00 sáng',       icon: CupertinoIcons.calendar, isEnabled: true),
    AlertSetting(title: 'Biến động nhiệt độ',         description: 'Thay đổi > 5°C so với hôm qua',               icon: CupertinoIcons.thermometer, isEnabled: false),
  ];
}
