import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorChatScreen extends StatefulWidget {
  final String patientName;
  final String patientId;

  const DoctorChatScreen({
    Key? key,
    required this.patientName,
    required this.patientId,
  }) : super(key: key);

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHistory() async {
    // In a real app, this would load from a backend
    setState(() {
      _messages.addAll([
        {
          'text': 'Hello Doctor, I have a question about my medication.',
          'isDoctor': false,
          'time': '10:30 AM',
        },
        {
          'text': 'Hello, I\'m here to help. What would you like to know?',
          'isDoctor': true,
          'time': '10:31 AM',
        },
        {
          'text':
              'I\'m experiencing some side effects from the new medication.',
          'isDoctor': false,
          'time': '10:32 AM',
        },
      ]);
    });
    _scrollToBottom();
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'text': _messageController.text,
      'isDoctor': true,
      'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
    };

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
    _scrollToBottom();

    // In a real app, this would save to a backend
    final prefs = await SharedPreferences.getInstance();
    final chatHistory =
        prefs.getStringList('chat_history_${widget.patientId}') ?? [];
    chatHistory.add(
        '${DateTime.now().toIso8601String()}|${message['text']}|${message['isDoctor']}');
    await prefs.setStringList('chat_history_${widget.patientId}', chatHistory);
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Align(
      alignment:
          message['isDoctor'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              message['isDoctor'] ? const Color(0xFF2D9CDB) : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text'],
              style: TextStyle(
                color: message['isDoctor'] ? Colors.white : Colors.black,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['time'],
              style: TextStyle(
                color: message['isDoctor']
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black54,
                fontSize: 10,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.patientName,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
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
              itemBuilder: (context, index) =>
                  _buildMessageBubble(_messages[index]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
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
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2D9CDB)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
