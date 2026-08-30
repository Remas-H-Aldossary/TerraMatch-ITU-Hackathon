import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  late final Dio _dio;
  
  // فصل الـ Base URL عن الـ Endpoint ليعمل Dio بشكل صحيح
  static const String _baseUrl = 'https://terramatch-knowledge-base.onrender.com';
  static const String _askEndpoint = '/ask';

  final List<String> _quickSuggestions = [
    'هل يمكن نقل بيانات المزارعين خارج المملكة؟',
    'How to improve soil NPK levels?',
    'Signs of nitrogen deficiency',
  ];

  @override
  void initState() {
    super.initState();
    _initDio();
    _messages.add(
      ChatMessage(
        text: 'مرحباً بك! أنا مستشارك الزراعي الذكي. كيف يمكنني مساعدتك اليوم؟',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 65),
        receiveTimeout: const Duration(seconds: 65),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      ),
    );
  }

  /// الدالة المسؤولة عن إرسال السؤال عبر Dio
  Future<String> _fetchAiResponse(String question) async {
    try {
      final response = await _dio.post(
        _askEndpoint,
        data: {
          'question': question,
          'top_k': 3,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // معالجة استجابة الـ API واستخراج النتيجة بناءً على المفاتيح الشائعة
        if (data is Map<String, dynamic>) {
          if (data.containsKey('answer')) {
            return data['answer'].toString();
          } else if (data.containsKey('response')) {
            return data['response'].toString();
          } else if (data.containsKey('result')) {
            return data['result'].toString();
          }
        }
        return data.toString();
      } else {
        return 'حدث خطأ في الاتصال بالسيرفر (${response.statusCode}). يرجى المحاولة لاحقاً.';
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'تأخرت الاستجابة بسبب إعادة تشغيل الخدمة، يرجى إعادة إرسال السؤال مرة أخرى.';
      }
      return 'تعذر الاتصال بالخادم، يرجى التأكد من اتصال الإنترنت.';
    } catch (e) {
      return 'حدث خطأ غير متوقع: $e';
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    // إرسال السؤال والحصول على الإجابة
    String aiResponse = await _fetchAiResponse(text);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.smart_toy_outlined, color: Colors.white, size: 18),
            ),
            SizedBox(width: 10),
            Text(
              'AI Agronomist',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Chat Messages List ---
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // --- Typing Indicator ---
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'جاري البحث في قاعدة المعرفة والاستجابة...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // --- Quick Suggestions ---
            if (_messages.length <= 2)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickSuggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ActionChip(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      label: Text(
                        _quickSuggestions[index],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () => _sendMessage(_quickSuggestions[index]),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            // --- Input Field ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'اسأل عن التربة أو المحاصيل أو الأنظمة...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: AppColors.background,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : const Color(0xFFE2F3E5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : AppColors.textDark,
            fontSize: 14,
            height: 1.3,
          ),
        ),
      ),
    );
  }
} 