import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/notification_service.dart';

class WeatherController extends GetxController {
  final WeatherService _service = WeatherService();
  final NotificationService _notificationService = NotificationService();
  
  var isLoading = true.obs;
  var weather = Rxn<WeatherInfo>();

  @override
  void onInit() {
    super.onInit();
    fetchCurrentWeather('Hanoi');
  }

  Future<void> fetchCurrentWeather(String cityName) async {
    try {
      isLoading(true);
      final result = await _service.fetchWeather(cityName);
      weather.value = result;
      
      // Sau khi lấy dữ liệu thành công, kiểm tra xem có cần cảnh báo không
      _checkAndNotify(result);
      
    } catch (e) {
      Get.snackbar('Lỗi kết nối', 'Không thể lấy dữ liệu cho $cityName.');
    } finally {
      isLoading(false);
    }
  }

  // Logic kiểm tra và gửi thông báo tự động
  Future<void> _checkAndNotify(WeatherInfo w) async {
    final prefs = await SharedPreferences.getInstance();
    final savedStatus = prefs.getStringList('weather_alerts');
    
    // Kiểm tra xem người dùng có bật "Cảnh báo mưa" (index 0 trong danh sách cài đặt) không
    bool isRainAlertEnabled = savedStatus != null && savedStatus.isNotEmpty && savedStatus[0] == 'true';

    if (isRainAlertEnabled) {
      if (w.condition == WeatherCondition.heavyRain || w.condition == WeatherCondition.thunderstorm) {
        await _notificationService.showNotification(
          id: 100, // ID riêng cho cảnh báo thời tiết xấu
          title: '⚠️ Cảnh báo thời tiết xấu',
          body: 'Tại ${w.cityName} đang có ${w.description}. Bạn nên hạn chế ra ngoài!',
        );
      }
    }
  }
}
