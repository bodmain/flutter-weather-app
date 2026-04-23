import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/controllers/ai_controller.dart';
import 'package:weather_app/models/weather_model.dart';

void main() {

  final weatherService = WeatherService();
  final aiController = AIController();

  // Dữ liệu giả lập để test AI
  const mockWeather = WeatherInfo(
    cityName: 'Hanoi',
    country: 'VN',
    temperature: 30.0,
    feelsLike: 32.0,
    tempMin: 25.0,
    tempMax: 33.0,
    humidity: 70,
    windSpeed: 10.0,
    uvIndex: 8,
    description: 'Trời nắng gắt',
    condition: WeatherCondition.sunny,
  );

  group('Kiểm thử Backend - WeatherNow', () {
    
    //  API THỜI TIẾT
    test('Test 1: Lấy dữ liệu thời tiết thực tế từ OpenWeatherMap', () async {
      print('--- Bắt đầu Test 1 ---');
      try {
        final result = await weatherService.fetchWeather('Hanoi');
        
        expect(result.cityName, isNotEmpty);
        expect(result.temperature, isA<double>());
        print('✅ Kết quả: Thành phố ${result.cityName} hiện tại là ${result.temperature}°C');
      } catch (e) {
        fail('❌ Lỗi API thời tiết: $e');
      }
    });

    // TEST API AI
    test('Test 2: Kiểm tra phản hồi từ Trợ lý AI Gemini', () async {
      print('--- Bắt đầu Test 2 ---');
      try {
        final response = await aiController.askAI('Thời tiết này có nên đi dã ngoại không?', mockWeather);
        
        expect(response, isNotEmpty);
        expect(response.length, greaterThan(10));
        print('✅ AI phản hồi thành công: ${response.substring(0, response.length > 100 ? 100 : response.length)}...');
      } catch (e) {
        fail('❌ Lỗi API AI: $e');
      }
    });
  });
}
