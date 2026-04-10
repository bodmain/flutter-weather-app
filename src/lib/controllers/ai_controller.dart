import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class AIController {
  // Dán API Key mới nhất bạn lấy từ Google AI Studio vào đây
  static const String _apiKey = 'AIzaSyDEz0lyCgb2dpsdykAIVau7U8jShSnDJu8';
  
  // URL gọi trực tiếp đến model Gemini 1.5 Flash
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<String> askAI(String question, WeatherInfo weather) async {
    try {
      // Chuẩn bị nội dung câu hỏi kèm ngữ cảnh thời tiết
      final prompt = """
      Bạn là trợ lý thời tiết thông minh tại ${weather.cityName}. 
      Thông tin hiện tại: ${weather.temperature}°C, ${weather.description}, UV: ${weather.uvIndex}.
      Người dùng hỏi: "$question"
      Hãy trả lời ngắn gọn, thân thiện và đưa ra lời khuyên thực tế.
      """;

      // Gửi yêu cầu POST trực tiếp
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 300,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Lấy nội dung phản hồi từ cấu trúc JSON của Google
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        final errorData = jsonDecode(response.body);
        return "Lỗi từ máy chủ AI (${response.statusCode}): ${errorData['error']['message']}";
      }
    } catch (e) {
      return "Lỗi kết nối: $e. Hãy kiểm tra Internet hoặc VPN.";
    }
  }
}
