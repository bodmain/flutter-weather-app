// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weather_app/main.dart';

void main() {
  testWidgets('Kiểm tra hiển thị tên thành phố mặc định', (WidgetTester tester) async {
    // 1. Chạy app
    await tester.pumpWidget(const WeatherApp());

    // 2. Kiểm tra xem có thấy chữ "Hà Nội" trên màn hình không
    expect(find.text('Hà Nội'), findsOneWidget);

    // 3. Kiểm tra xem có icon địa điểm không
    expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
  });
}