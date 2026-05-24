import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yukgo_flutter/core/theme/app_theme.dart';
import 'package:yukgo_flutter/core/theme/theme_ext.dart';
import 'package:yukgo_flutter/core/utils/user_session.dart';
import 'package:yukgo_flutter/core/services/token_storage.dart';
import 'package:yukgo_flutter/core/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;       // "order_123"
  final String otherName;    // Kimga chat qilayapti

  const ChatScreen({super.key, required this.roomId, required this.otherName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  WebSocketChannel? _channel;
  final List<_Msg> _messages = [];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _connected = false;
  bool _connecting = true;
  StreamSubscription? _sub;
  int _retryDelaySeconds = 3;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    final token = await TokenStorage.getToken();
    if (token == null) return;
    try {
      final uri = Uri.parse('${ApiService.wsBase}/${widget.roomId}?token=$token');
      _channel = WebSocketChannel.connect(uri);
      _sub = _channel!.stream.listen(
        _onData,
        onError: (_) => _onDisconnect(),
        onDone: _onDisconnect,
      );
      if (mounted) setState(() { _connected = true; _connecting = false; _retryDelaySeconds = 3; });
    } catch (_) {
      if (mounted) setState(() { _connected = false; _connecting = false; });
    }
  }

  void _onData(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      if (data['type'] == 'history') {
        final list = (data['messages'] as List).cast<Map<String, dynamic>>();
        if (mounted) setState(() {
          _messages.clear();
          _messages.addAll(list.map(_Msg.fromJson));
        });
        _scrollToBottom();
      } else if (data['type'] == 'message') {
        if (mounted) setState(() => _messages.add(_Msg.fromJson(data)));
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _onDisconnect() {
    if (mounted) setState(() => _connected = false);
    Future.delayed(Duration(seconds: _retryDelaySeconds), () {
      if (mounted && !_connected && !_connecting) _connect();
    });
    _retryDelaySeconds = (_retryDelaySeconds * 2).clamp(3, 60);
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || !_connected) return;
    _channel?.sink.add(jsonEncode({'content': text}));
    _ctrl.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _channel?.sink.close();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = UserSession.darkMode.value;
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primary.withOpacity(0.15),
            child: Text(
              widget.otherName.isNotEmpty ? widget.otherName[0].toUpperCase() : '?',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.otherName,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
            Text(
              _connecting ? 'Ulanmoqda...' : _connected ? 'Onlayn' : 'Oflayn',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _connected ? Colors.green : Colors.grey,
              ),
            ),
          ]),
        ]),
        actions: [
          if (!_connected && !_connecting)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.primary),
              onPressed: _connect,
            ),
        ],
      ),
      body: Column(children: [
        // Messages
        Expanded(
          child: _connecting && _messages.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _messages.isEmpty
                  ? Center(child: Text("Hali xabar yo'q. Birinchi bo'lib yozing!",
                      style: GoogleFonts.inter(color: context.textMuted)))
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _buildBubble(_messages[i], isDark),
                    ),
        ),

        // Input
        Container(
          padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
          decoration: BoxDecoration(
            color: context.cardColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: GoogleFonts.inter(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: "Xabar yozing...",
                  hintStyle: GoogleFonts.inter(color: context.textMuted),
                  filled: true,
                  fillColor: context.inputColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.send,
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: _connected ? AppTheme.primary : Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBubble(_Msg msg, bool isDark) {
    final isMe = msg.senderId == _myId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.primary
              : (isDark ? const Color(0xFF1E2640) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(msg.senderName,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
            const SizedBox(height: 2),
            Text(msg.content,
                style: GoogleFonts.inter(
                    fontSize: 14, color: isMe ? Colors.white : context.textPrimary)),
            const SizedBox(height: 4),
            Text(_formatTime(msg.createdAt),
                style: GoogleFonts.inter(
                    fontSize: 10, color: isMe ? Colors.white60 : context.textMuted)),
          ],
        ),
      ),
    );
  }

  int get _myId {
    // UserSession dan user id olish — token dan yoki session dan
    return UserSession.userId;
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Msg {
  final int id;
  final int senderId;
  final String senderName;
  final String content;
  final DateTime? createdAt;

  _Msg({required this.id, required this.senderId, required this.senderName,
      required this.content, this.createdAt});

  factory _Msg.fromJson(Map<String, dynamic> j) => _Msg(
    id: j['id'] ?? 0,
    senderId: j['sender_id'] ?? 0,
    senderName: j['sender_name'] ?? '',
    content: j['content'] ?? '',
    createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
  );
}
