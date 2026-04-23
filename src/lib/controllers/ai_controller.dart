import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class AIController {

  static const String _apiKey = 'AIzaSyDT5--XWAVD5GEwF1QRliBms1BUmLSU05E';

  static const String _modelId = 'gemini-3-flash-preview';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$_modelId:generateContent';

  Future<String> askAI(String question, WeatherInfo weather) async {
    if (_apiKey.isEmpty) return "Lỗi: Bạn chưa cấu hình API Key.";

    try {
      //  Prompt để AI tư vấn sâu hơn
      final prompt = """
      Bạn là trợ lý thời tiết thông minh và tận tâm.
      Bối cảnh: Tại ${weather.cityName}, nhiệt độ ${weather.temperature}°C, trạng thái: ${weather.description}, độ ẩm ${weather.humidity}%.
      
      Yêu cầu:
      - Trả lời câu hỏi: "$question"
      - Dựa trên dữ liệu thời tiết, hãy phân tích xem hoạt động người dùng hỏi có phù hợp không và đưa ra lời khuyên cụ thể (trang phục, sức khỏe, an toàn).
      - Trả lời bằng tiếng Việt, giọng điệu thân thiện, tự nhiên. 
      - Câu trả lời không quá dài nhưng phải đầy đủ ý, không được bỏ dở giữa chừng.
      """;

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [{"text": prompt}]
            }
          ],
          "generationConfig": {
            "temperature": 0.8,
            "maxOutputTokens": 800,
            "topP": 0.95,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text.trim();
        } else {
          return "AI đang suy nghĩ nhưng chưa đưa ra câu trả lời phù hợp. Bạn thử hỏi cách khác nhé!";
        }
      } else {
        log("AI Error Response: ${response.body}");
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? "Lỗi không xác định";
        return "Trợ lý đang bận một chút ($errorMessage).";
      }
    } catch (e) {
      log("Connection Error: $e");
      return "Không thể kết nối với trợ lý. Vui lòng kiểm tra internet.";
    }
  }
}