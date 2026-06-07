import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageCtrl    = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pesan selamat datang dari bot
    _messages.add(_ChatMessage(
      text    : 'Halo! Saya BeautyBot 💄 Saya bisa membantu kamu mencari MUA, cek harga, dan membuat booking. Ada yang bisa saya bantu?',
      isBot   : true,
      intent  : 'salam',
    ));
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── POST /api/chatbot/message ────────────────────────────────────
  // Field: message (string, max 500 karakter)
  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Tampilkan pesan user
    setState(() {
      _messages.add(_ChatMessage(text: text, isBot: false));
      _isLoading = true;
    });
    _messageCtrl.clear();
    _scrollToBottom();

    try {
      final result = await ApiService.sendChatMessage(text);

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          _messages.add(_ChatMessage(
            text  : data['message'] ?? 'Maaf, tidak ada respons.',
            isBot : true,
            intent: data['intent'],
          ));
        });
      } else {
        setState(() {
          _messages.add(_ChatMessage(
            text : 'Maaf, terjadi kesalahan. Coba lagi ya!',
            isBot: true,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          text : 'Tidak bisa terhubung ke server. Periksa koneksi internet kamu.',
          isBot: true,
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve   : Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title          : const Row(
          children: [
            CircleAvatar(
              radius         : 16,
              backgroundColor: Colors.white,
              child          : Icon(Icons.face_retouching_natural, color: Color(0xFFE91E8C), size: 20),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children          : [
                Text('BeautyBot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Online', style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // ── Suggestion chips ───────────────────────────────────
          Container(
            color  : Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child  : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child          : Row(
                children: [
                  'Cari MUA wedding',
                  'MUA terbaik Bandung',
                  'Berapa harga makeup?',
                  'MUA verified',
                ].map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child  : ActionChip(
                    label    : Text(s, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _messageCtrl.text = s;
                      _sendMessage();
                    },
                    backgroundColor: const Color(0xFFE91E8C).withValues(alpha: 0.1),
                    side           : const BorderSide(color: Color(0xFFE91E8C), width: 0.5),
                  ),
                )).toList(),
              ),
            ),
          ),

          // ── Chat messages ──────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller  : _scrollController,
              padding     : const EdgeInsets.all(16),
              itemCount   : _messages.length,
              itemBuilder : (_, i) => _ChatBubble(message: _messages[i]),
            ),
          ),

          // ── Loading indicator ──────────────────────────────────
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child  : Row(
                children: [
                  CircleAvatar(
                    radius         : 16,
                    backgroundColor: Color(0xFFE91E8C),
                    child          : Icon(Icons.face_retouching_natural, color: Colors.white, size: 16),
                  ),
                  SizedBox(width: 8),
                  _TypingIndicator(),
                ],
              ),
            ),

          // ── Input field ────────────────────────────────────────
          Container(
            padding  : const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color     : Colors.white,
              boxShadow : [
                BoxShadow(
                  color  : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset : const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top  : false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller  : _messageCtrl,
                      maxLength   : 500, // sesuai validasi Laravel
                      maxLines    : null,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                      decoration  : InputDecoration(
                        hintText        : 'Ketik pesan...',
                        border          : OutlineInputBorder(
                          borderRadius  : BorderRadius.circular(24),
                          borderSide    : BorderSide.none,
                        ),
                        filled          : true,
                        fillColor       : Colors.grey[100],
                        contentPadding  : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE91E8C),
                    child          : IconButton(
                      icon    : const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data model pesan chat ─────────────────────────────────────────
class _ChatMessage {
  final String  text;
  final bool    isBot;
  final String? intent;

  _ChatMessage({required this.text, required this.isBot, this.intent});
}

// ─── Widget: Chat Bubble ───────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child  : Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            const CircleAvatar(
              radius         : 16,
              backgroundColor: Color(0xFFE91E8C),
              child          : Icon(Icons.face_retouching_natural, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding    : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration : BoxDecoration(
                color       : isBot ? Colors.white : const Color(0xFFE91E8C),
                borderRadius: BorderRadius.only(
                  topLeft    : const Radius.circular(18),
                  topRight   : const Radius.circular(18),
                  bottomLeft : Radius.circular(isBot ? 4 : 18),
                  bottomRight: Radius.circular(isBot ? 18 : 4),
                ),
                boxShadow  : [
                  BoxShadow(
                    color     : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset    : const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color : isBot ? Colors.black87 : Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─── Typing indicator ──────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding    : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration : BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children    : List.generate(3, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child  : Container(
            width : 6,
            height: 6,
            decoration: const BoxDecoration(
              color : Colors.grey,
              shape : BoxShape.circle,
            ),
          ),
        )),
      ),
    );
  }
}