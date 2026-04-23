import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = 'ff90cfe4876570e3abd71cdead590092'; 
  static const String _authority = 'api.openweathermap.org';
  static const String _path = '/data/2.5/weather';

  Future<WeatherInfo> fetchWeather(String cityName) async {
    // Chuẩn hóa tên thành phố cho API
    String queryName = cityName;
    if (cityName.toLowerCase().contains('hồ chí minh') || cityName.toLowerCase().contains('ho chi minh')) {
      queryName = 'Ho Chi Minh City'; // Tên chuẩn API nhận diện tốt nhất
    }

    final uri = Uri.https(_authority, _path, {
      'q': queryName,
      'appid': _apiKey,
      'units': 'metric',
      'lang': 'vi',
    });
    
    log('Requesting Weather for: $queryName');
    
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return WeatherInfo.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy thành phố: $cityName');
      } else {
        throw Exception('Lỗi hệ thống: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không có kết nối Internet.');
    } catch (e) {
      throw Exception('Lỗi kết nối máy chủ.');
    }
  }
}
