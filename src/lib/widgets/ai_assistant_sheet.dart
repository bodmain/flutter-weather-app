import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../controllers/ai_controller.dart';
import '../theme/app_theme.dart';

class AIAssistantSheet extends StatefulWidget {
  final WeatherInfo weather;
  const AIAssistantSheet({super.key, required this.weather});

  @override
  State<AIAssistantSheet> createState() => _AIAssistantSheetState();
}

class _AIAssistantSheetState extends State<AIAssistantSheet> {
  final AIController _aiController = AIController();
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'ai',
      'text': 'Xin chào! Tôi là trợ lý thời tiết AI. Dựa trên tình hình thời tiết tại ${widget.weather.cityName}, bạn muốn tôi tư vấn điều gì không?'
    });
  }

  void _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _textCtrl.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await _aiController.askAI(text, widget.weather);

    setState(() {
      _messages.add({'role': 'ai', 'text': response});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNight = widget.weather.isNight;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isNight ? AppColors.bg1 : Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isNight ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(CupertinoIcons.sparkles, color: AppColors.accent, size: 24),
                const SizedBox(width: 10),
                Text('Trợ lý thời tiết AI', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: isNight ? Colors.white : AppColors.bg0)),
                const Spacer(),
                IconButton(icon: const Icon(CupertinoIcons.xmark_circle_fill), onPressed: () => Navigator.pop(context), color: isNight ? Colors.white24 : Colors.black26),
              ],
            ),
          ),
          const Divider(),

          // Chat Content
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isAI = msg['role'] == 'ai';
                return Align(
                  alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isAI 
                          ? (isNight ? Colors.white.withValues(alpha: 0.05) : Colors.white)
                          : AppColors.accent,
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomLeft: isAI ? const Radius.circular(0) : const Radius.circular(20),
                        bottomRight: isAI ? const Radius.circular(20) : const Radius.circular(0),
                      ),
                      border: isAI ? Border.all(color: isNight ? Colors.white10 : Colors.black.withValues(alpha: 0.05)) : null,
                    ),
                    child: Text(
                      msg['text']!,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isAI ? (isNight ? Colors.white : AppColors.bg0) : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoActivityIndicator(),
            ),

          // Input
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    onSubmitted: (_) => _sendMessage(),
                    style: GoogleFonts.nunito(color: isNight ? Colors.white : AppColors.bg0),
                    decoration: InputDecoration(
                      hintText: 'Hỏi AI về kế hoạch của bạn...',
                      hintStyle: GoogleFonts.nunito(color: isNight ? Colors.white38 : Colors.black38),
                      filled: true,
                      fillColor: isNight ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.arrow_up, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
