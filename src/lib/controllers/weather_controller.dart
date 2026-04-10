import 'package:get/get.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherController extends GetxController {
  final WeatherService _service = WeatherService();
  
  // Trạng thái dữ liệu cho Trang chủ
  var isLoading = true.obs;
  var weather = Rxn<WeatherInfo>();

  @override
  void onInit() {
    super.onInit();
    // Tự động lấy thời tiết Hà Nội khi app khởi động
    fetchCurrentWeather('Hanoi');
  }

  Future<void> fetchCurrentWeather(String cityName) async {
    try {
      isLoading(true);
      final result = await _service.fetchWeather(cityName);
      weather.value = result;
    } catch (e) {
      Get.snackbar('Lỗi kết nối', 'Không thể lấy dữ liệu cho $cityName. Hãy kiểm tra Internet và API Key.');
    } finally {
      isLoading(false);
    }
  }
}
