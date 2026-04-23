import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
    Future.delayed(const Duration(milliseconds: 350), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNight = widget.weather.isNight;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isNight ? AppColors.bg1 : Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: isNight ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(CupertinoIcons.sparkles, color: AppColors.accent, size: 24),
                const SizedBox(width: 10),
                Text('Trợ lý AI', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: isNight ? Colors.white : AppColors.bg0)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(CupertinoIcons.xmark_circle_fill, color: isNight ? Colors.white24 : Colors.black26),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isAI = msg['role'] == 'ai';
                return _buildChatBubble(msg['text']!, isAI, isNight);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: CupertinoActivityIndicator(),
            ),
          _buildInputArea(isNight),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isAI, bool isNight) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isAI 
              ? (isNight ? Colors.white.withValues(alpha: 0.05) : Colors.white)
              : AppColors.accent,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomLeft: isAI ? const Radius.circular(0) : const Radius.circular(18),
            bottomRight: isAI ? const Radius.circular(18) : const Radius.circular(0),
          ),
        ),
        child: isAI 
          ? MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: isNight ? Colors.white : AppColors.bg0, height: 1.5),
                strong: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: isNight ? Colors.white : AppColors.bg0),
                listBullet: GoogleFonts.nunito(color: AppColors.accent),
              ),
            )
          : Text(
              text,
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
      ),
    );
  }

  Widget _buildInputArea(bool isNight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: isNight ? AppColors.bg1 : Colors.blue.shade50,
        border: Border(top: BorderSide(color: isNight ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              onSubmitted: (_) => _sendMessage(),
              style: GoogleFonts.nunito(color: isNight ? Colors.white : AppColors.bg0, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Hỏi AI...',
                hintStyle: GoogleFonts.nunito(color: isNight ? Colors.white38 : Colors.black38),
                filled: true,
                fillColor: isNight ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
    );
  }
}
