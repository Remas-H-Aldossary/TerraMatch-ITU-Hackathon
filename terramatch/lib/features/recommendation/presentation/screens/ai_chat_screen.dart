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

  static const String _baseUrl = 'https://terramatch-knowledge-base.onrender.com';
  static const String _askEndpoint = '/ask';

  @override
  void initState() {
    super.initState();
    _initDio();
    _messages.add(
      ChatMessage(
        text: 'Hello! I am your AI Agronomist. How can I help you with your crop and soil management today?',
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
        return 'Server error (${response.statusCode}). Please try again later.';
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Response timed out due to cold start. Please resend your question.';
      }
      return 'Could not connect to the server. Please check your internet connection.';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  void _sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    final userMessage = ChatMessage(
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    String aiResponse = await _fetchAiResponse(query);

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
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Agronomist',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Knowledge Assistant',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // --- Typing Indicator ---
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Thinking...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // --- Floating Input Bar ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F4),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: AppColors.textDark, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Ask anything about your crops...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _sendMessage(_controller.text),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
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
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : AppColors.textDark,
            fontSize: 14.5,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}