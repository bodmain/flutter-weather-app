import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class SearchController extends GetxController {
  final TickerProvider vsync;
  final Function(WeatherInfo) onCitySelected;
  final WeatherService _service = WeatherService();

  final TextEditingController textCtrl = TextEditingController();
  final FocusNode focusNode = FocusNode();
  
  static List<WeatherInfo> history = [];
  
  var results = <WeatherInfo>[].obs;
  var isSearching = false.obs;
  bool hasText = false;

  late AnimationController listCtrl;

  SearchController({required this.vsync, required this.onCitySelected}) {
    listCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 400),
    )..forward();
    
    // Khởi tạo danh sách ban đầu là lịch sử hoặc gợi ý
    results.value = history.isNotEmpty ? history : WeatherData.cities;
  }

  // Hàm tìm kiếm từ API khi người dùng nhập
  void onTextChanged(String q) async {
    hasText = q.trim().isNotEmpty;
    
    if (!hasText) {
      results.value = history.isNotEmpty ? history : WeatherData.cities;
      return;
    }

    if (q.length < 2) return; // Chỉ tìm khi nhập từ 2 ký tự

    try {
      isSearching(true);
      // Gọi API để lấy thời tiết của thành phố đang gõ
      // Lưu ý: Để tối ưu, trong thực tế nên dùng debounce (đợi người dùng ngừng gõ)
      final cityWeather = await _service.fetchWeather(q);
      results.value = [cityWeather]; // Hiển thị kết quả tìm thấy
    } catch (e) {
      // Nếu không tìm thấy thành phố từ API, lọc trong list mockup
      results.value = WeatherData.cities.where((c) =>
          c.cityName.toLowerCase().contains(q.toLowerCase())).toList();
    } finally {
      isSearching(false);
      listCtrl.forward(from: 0);
    }
  }

  void clearSearch() {
    textCtrl.clear();
    hasText = false;
    results.value = history.isNotEmpty ? history : WeatherData.cities;
    focusNode.requestFocus();
    HapticFeedback.selectionClick();
  }

  void selectCity(WeatherInfo selectedCity) {
    HapticFeedback.mediumImpact();

    // Cập nhật lịch sử
    history.removeWhere((c) => c.cityName == selectedCity.cityName);
    history.insert(0, selectedCity);
    if (history.length > 5) history.removeLast();

    textCtrl.clear(); 
    hasText = false;

    onCitySelected(selectedCity);
  }

  @override
  void onClose() {
    textCtrl.dispose();
    focusNode.dispose();
    listCtrl.dispose();
    super.onClose();
  }
}
