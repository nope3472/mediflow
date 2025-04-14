import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class ChatConsultation extends StatefulWidget {
  final String? sharedFileContent;

  const ChatConsultation({super.key, this.sharedFileContent});

  @override
  State<ChatConsultation> createState() => _ChatConsultationState();
}

class _ChatConsultationState extends State<ChatConsultation> {
  final TextEditingController _textController = TextEditingController();
  final List<Widget> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late SharedPreferences _prefs;
  String? _lastQuestion;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    // If there's shared file content, add it as the first message
    if (widget.sharedFileContent != null) {
      _messages.add(_buildMessage(widget.sharedFileContent!, isUser: true));
    }
  }

  Future<void> _initializeChat() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadChatHistory();

      // Add welcome message
      final welcomeMessage =
          'Hello! I\'m Dr. Sarah Johnson. How can I help you today?';
      setState(() {
        _messages.add(_buildMessage(welcomeMessage, isUser: false));
      });
      _saveMessage(welcomeMessage, false);
    } catch (e) {
      developer.log('Error initializing chat: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final chatDoc = _prefs.getString('doctor_chat_document');
      if (chatDoc == null) return;

      final chatData = jsonDecode(chatDoc) as Map<String, dynamic>;
      final messages = chatData['messages'] as List<dynamic>;

      // Sort messages by timestamp to ensure correct order
      messages.sort((a, b) {
        final dateA = DateTime.parse(a['timestamp']);
        final dateB = DateTime.parse(b['timestamp']);
        return dateA.compareTo(dateB);
      });

      setState(() {
        _messages.clear();
        for (var msg in messages) {
          _messages.add(_buildMessage(msg['text'], isUser: msg['isUser']));
        }
      });
    } catch (e) {
      developer.log('Error loading chat history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chat history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveMessage(String text, bool isUser) async {
    try {
      final chatDoc = _prefs.getString('doctor_chat_document');
      Map<String, dynamic> chatData;
      List<dynamic> messages;

      if (chatDoc == null) {
        chatData = {
          'messages': [],
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        messages = [];
      } else {
        chatData = jsonDecode(chatDoc) as Map<String, dynamic>;
        messages = chatData['messages'] as List<dynamic>;
      }

      final newMessage = {
        'timestamp': DateTime.now().toIso8601String(),
        'text': text,
        'isUser': isUser,
      };

      messages.add(newMessage);
      chatData['messages'] = messages;
      chatData['lastUpdated'] = DateTime.now().toIso8601String();

      await _prefs.setString('doctor_chat_document', jsonEncode(chatData));
    } catch (e) {
      developer.log('Error saving message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2D9CDB) : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _messages.add(_buildMessage(text, isUser: true));
      _textController.clear();
    });

    await _saveMessage(text, true);

    // Simulate doctor's response (in a real app, this would be replaced with actual doctor responses)
    await Future.delayed(const Duration(seconds: 1));

    final response = 'I understand your concern. Let me help you with that.';
    setState(() {
      _messages.add(_buildMessage(response, isUser: false));
    });
    await _saveMessage(response, false);

    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Chat with Doctor',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2D9CDB)),
                      ),
                    ),
                    onSubmitted: _sendMessage,
                    enabled: !_isLoading,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2D9CDB)),
                  onPressed: !_isLoading
                      ? () => _sendMessage(_textController.text)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
