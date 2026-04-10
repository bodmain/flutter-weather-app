import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // Dán API Key thật của bạn vào đây
  static const String _apiKey = 'ff90cfe4876570e3abd71cdead590092'; 
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherInfo> fetchWeather(String cityName) async {
    final url = '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric&lang=vi';
    
    // In ra URL để kiểm chứng
    log('--- ĐANG GỌI API: $url ---');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // In dữ liệu thô nhận được từ vệ tinh
        log('--- DỮ LIỆU TỪ API: $data ---');
        
        return WeatherInfo.fromJson(data);
      } else {
        log('--- LỖI API: ${response.statusCode} - ${response.body} ---');
        throw Exception('Lỗi lấy dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      log('--- LỖI KẾT NỐI: $e ---');
      rethrow;
    }
  }
}
