import 'dart:async';
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
  
  // Chuyển history thành RxList để có thể quan sát được
  static var history = <WeatherInfo>[].obs;
  
  var results = <WeatherInfo>[].obs;
  var isSearching = false.obs;
  var hasText = false.obs; // Chuyển thành RxBool
  Timer? _debounce;

  late AnimationController listCtrl;

  SearchController({required this.vsync, required this.onCitySelected}) {
    listCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 400),
    )..forward();
    
    results.assignAll(history.isNotEmpty ? history : WeatherData.cities);
  }

  void onTextChanged(String q) {
    hasText.value = q.trim().isNotEmpty;
    
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (!hasText.value) {
      results.assignAll(history.isNotEmpty ? history : WeatherData.cities);
      isSearching(false);
      return;
    }

    if (q.length < 2) return;

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _executeSearch(q);
    });
  }

  Future<void> _executeSearch(String q) async {
    try {
      isSearching(true);
      results.clear(); 
      
      final cityWeather = await _service.fetchWeather(q);
      results.assignAll([cityWeather]);
    } catch (e) {
      results.assignAll(WeatherData.cities.where((c) =>
          c.cityName.toLowerCase().contains(q.toLowerCase())).toList());
    } finally {
      isSearching(false);
      listCtrl.forward(from: 0);
    }
  }

  void clearSearch() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    textCtrl.clear();
    hasText.value = false;
    isSearching(false);
    results.assignAll(history.isNotEmpty ? history : WeatherData.cities);
    focusNode.requestFocus();
    HapticFeedback.selectionClick();
  }

  void selectCity(WeatherInfo selectedCity) {
    HapticFeedback.mediumImpact();

    history.removeWhere((c) => c.cityName == selectedCity.cityName);
    history.insert(0, selectedCity);
    if (history.length > 5) history.removeLast();

    textCtrl.clear(); 
    hasText.value = false;

    onCitySelected(selectedCity);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textCtrl.dispose();
    focusNode.dispose();
    listCtrl.dispose();
    super.onClose();
  }
}
