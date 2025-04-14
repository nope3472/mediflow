import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'chat_consultation.dart';
import 'dart:developer' as developer;
import 'package:medi_flow_new/services/firestore_service.dart';

class ReportHistory extends StatefulWidget {
  const ReportHistory({Key? key}) : super(key: key);

  @override
  State<ReportHistory> createState() => _ReportHistoryState();
}

class _ReportHistoryState extends State<ReportHistory> {
  List<Map<String, dynamic>> _chatHistory = [];
  bool _isLoading = true;
  late SharedPreferences _prefs;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      setState(() => _isLoading = true);

      final messages = await _firestoreService.getChatMessages().first;
      final List<Map<String, dynamic>> chatHistory = [];

      for (var i = 0; i < messages.docs.length; i++) {
        final message = messages.docs[i].data() as Map<String, dynamic>;
        if (message['isUser'] == true) {
          // This is a user message (answer)
          if (i > 0) {
            final prevMessage =
                messages.docs[i - 1].data() as Map<String, dynamic>;
            if (prevMessage['isUser'] == false) {
              // Previous message was a question
              chatHistory.add({
                'question': prevMessage['text'],
                'answer': message['text'],
                'timestamp': message['timestamp'],
              });
            }
          }
        }
      }

      setState(() {
        _chatHistory = chatHistory;
        _isLoading = false;
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareChatHistory() async {
    try {
      final chatDoc = _prefs.getString('chat_document');
      if (chatDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No chat history to share'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final chatData = jsonDecode(chatDoc) as Map<String, dynamic>;
      final messages = chatData['messages'] as List<dynamic>;

      // Sort messages by timestamp to ensure correct order
      messages.sort((a, b) {
        final dateA = DateTime.parse(a['timestamp']);
        final dateB = DateTime.parse(b['timestamp']);
        return dateA.compareTo(dateB);
      });

      // Format messages for sharing
      final StringBuffer content = StringBuffer();
      content.writeln('Medical Consultation History\n');

      for (var msg in messages) {
        final date = DateTime.parse(msg['timestamp']);
        final formattedDate = DateFormat('MMM d, y h:mm a').format(date);
        content.writeln('Date: $formattedDate');
        content.writeln('Q: ${msg['question'] ?? msg['text'] ?? ''}');
        content.writeln('A: ${msg['answer'] ?? ''}');
        content.writeln('----------------------------------------\n');
      }

      // Create a temporary file to share
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/medical_history.txt');
      await file.writeAsString(content.toString());

      // Navigate to ChatConsultation screen with the file content
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConsultation(
              sharedFileContent: content.toString(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing chat history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Chat History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black54),
            onPressed: _shareChatHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No chat history yet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final chat = _chatHistory[index];
                    final date = DateTime.parse(chat['timestamp']);
                    final formattedDate = DateFormat('MMM d, y').format(date);
                    final formattedTime = DateFormat('h:mm a').format(date);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  formattedTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Q: ${chat['question']}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'A: ${chat['answer']}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
