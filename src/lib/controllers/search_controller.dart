import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/weather_model.dart';

class SearchController {
  final TickerProvider vsync;
  final Function(WeatherInfo) onCitySelected;

  final TextEditingController textCtrl = TextEditingController();
  final FocusNode focusNode = FocusNode();
  
  // Danh sách lịch sử tìm kiếm
  static List<WeatherInfo> history = [];
  
  List<WeatherInfo> results = history.isNotEmpty ? history : WeatherData.cities;
  int? selectedIdx;
  bool hasText = false;

  late AnimationController listCtrl;

  SearchController({required this.vsync, required this.onCitySelected}) {
    listCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 400),
    )..forward();
    
    textCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final q = textCtrl.text.trim().toLowerCase();
    hasText = q.isNotEmpty;
    
    if (hasText) {
      results = WeatherData.cities.where((c) =>
          c.cityName.toLowerCase().contains(q)).toList();
    } else {
      // Nếu xóa hết chữ, hiện lại lịch sử (nếu có) hoặc gợi ý
      results = history.isNotEmpty ? history : WeatherData.cities;
    }
    
    listCtrl.forward(from: 0);
  }

  void clearSearch() {
    textCtrl.clear();
    focusNode.requestFocus();
    HapticFeedback.selectionClick();
  }

  void selectCity(int index) {
    final selectedCity = results[index];
    selectedIdx = index;
    HapticFeedback.mediumImpact();

    // 1. Cập nhật lịch sử (đưa lên đầu, không trùng lặp)
    history.removeWhere((c) => c.cityName == selectedCity.cityName);
    history.insert(0, selectedCity);
    if (history.length > 5) history.removeLast(); // Giới hạn 5 mục

    // 2. Xóa nội dung tìm kiếm để lần sau vào lại sẽ thấy lịch sử
    textCtrl.clear(); 
    hasText = false;

    // 3. Chuyển trang
    onCitySelected(selectedCity);
  }

  void dispose() {
    textCtrl.removeListener(_onTextChanged);
    textCtrl.dispose();
    focusNode.dispose();
    listCtrl.dispose();
  }
}
