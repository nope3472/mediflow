import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medi_flow_new/login.dart';
import 'package:medi_flow_new/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medi_flow_new/home_dashboard.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:medi_flow_new/models/patient_profile.dart';
import 'package:medi_flow_new/services/medical_history_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medi_flow_new/services/firestore_service.dart';

// Create a global service for AI
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final String _geminiApiKey = "AIzaSyCcrDqdZsv-aExddRmxENSgCE8lBundBsA";
  late final Gemini gemini;
  final Dio _dio = Dio();
  bool _isInitialized = false;
  String? _lastError;

  String? get lastError => _lastError;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      developer.log(
        'Initializing AIService with API key: ${_geminiApiKey.substring(0, 5)}...',
      );
      gemini = Gemini.instance;
      Gemini.init(apiKey: _geminiApiKey, enableDebugging: true);
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => developer.log(obj.toString()),
        ),
      );
      _isInitialized = true;
      _lastError = null;
      developer.log('AIService initialized successfully');
    } catch (e) {
      _lastError = e.toString();
      developer.log('Error initializing AIService: $_lastError');
      _isInitialized = false;
    }
  }

  // Method to send text messages using Gemini
  Future<String?> sendTextMessage(String text) async {
    try {
      if (!_isInitialized) {
        developer.log('AIService not initialized, initializing now...');
        await initialize();
      }
      developer.log('Sending text message: $text');

      try {
        final result = await gemini.text(text);
        developer.log('Gemini response: ${result?.output}');
        return result?.output;
      } catch (packageError) {
        developer.log(
          'Package error: $packageError - Falling back to direct API',
        );

        final response = await _dio.post(
          'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent',
          queryParameters: {'key': _geminiApiKey},
          data: {
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': text},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.7,
              'topK': 40,
              'topP': 0.95,
              'maxOutputTokens': 1024,
            },
          },
        );

        developer.log('Direct API response status: ${response.statusCode}');
        developer.log('Direct API response data: ${response.data}');

        if (response.statusCode == 200 && response.data != null) {
          try {
            final text =
                response.data['candidates'][0]['content']['parts'][0]['text'];
            developer.log('Extracted text from response: $text');
            return text;
          } catch (e) {
            developer.log('Error parsing response: $e');
            developer.log('Response data: ${response.data}');
            return "Sorry, I couldn't process that correctly.";
          }
        }
        return null;
      }
    } catch (e) {
      _lastError = e.toString();
      developer.log('Error sending message: $_lastError');
      return null;
    }
  }

  // Method to handle image analysis
  Future<String?> analyzeImage(List<int> imageBytes, String prompt) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final result = await gemini.textAndImage(
        text: prompt,
        image: Uint8List.fromList(imageBytes),
      );
      return result?.output;
    } catch (e) {
      _lastError = e.toString();
      developer.log('Error analyzing image: $_lastError');
      return null;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize the AI service
  final aiService = AIService();
  await aiService.initialize();

  // Log startup info for debugging
  developer.log(
    'App starting with AI service. Initialized: ${aiService.isInitialized}',
  );
  if (aiService.lastError != null) {
    developer.log('AI initialization error: ${aiService.lastError}');
  }

  runApp(const MediFlowApp());
}

class MediFlowApp extends StatelessWidget {
  const MediFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const EntryPoint(),
    );
  }
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  Widget? _startScreen;

  @override
  void initState() {
    super.initState();
    determineStartScreen();
  }

  Future<void> determineStartScreen() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _startScreen = const LoginScreen());
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

      if (onboardingDone) {
        setState(
          () => _startScreen = HomeDashboard(
            userName: user.displayName ?? 'User',
          ),
        );
      } else {
        setState(() => _startScreen = const OnboardingScreen());
      }
    } catch (e) {
      developer.log('Error determining start screen: $e');
      // Fallback to login screen in case of errors
      setState(() => _startScreen = const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_startScreen == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading MediFlow...'),
            ],
          ),
        ),
      );
    } else {
      return _startScreen!;
    }
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Widget> _messages = [];
  final AIService _aiService = AIService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  String? _lastQuestion;

  // Pre-visit questionnaire state
  bool _isPreVisitMode = true;
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _preVisitResponses = {};

  // Pre-visit questions
  final List<Map<String, dynamic>> _preVisitQuestions = [
    {
      'section': 'Identification',
      'question': 'What is your full name?',
      'key': 'fullName',
      'type': 'text'
    },
    {
      'section': 'Identification',
      'question': 'What is your age?',
      'key': 'age',
      'type': 'number'
    },
    {
      'section': 'Identification',
      'question': 'What is your contact number?',
      'key': 'contactNumber',
      'type': 'phone'
    },
    {
      'section': 'Visit Reason',
      'question':
          'Why did you book this visit? (Please describe in your own words)',
      'key': 'visitReason',
      'type': 'text'
    },
    {
      'section': 'Visit Reason',
      'question': 'How long have you been experiencing these issues?',
      'key': 'duration',
      'type': 'text'
    },
    {
      'section': 'Symptoms',
      'question': 'What are your main symptoms?',
      'key': 'mainSymptoms',
      'type': 'text'
    },
    {
      'section': 'Symptoms',
      'question': 'Have you noticed any other related symptoms?',
      'key': 'relatedSymptoms',
      'type': 'text'
    },
    {
      'section': 'Medical History',
      'question': 'Do you have any chronic conditions?',
      'key': 'chronicConditions',
      'type': 'text'
    },
    {
      'section': 'Medical History',
      'question': 'Are you currently taking any medications?',
      'key': 'currentMedications',
      'type': 'text'
    },
    {
      'section': 'Medical History',
      'question': 'Do you have any allergies?',
      'key': 'allergies',
      'type': 'text'
    },
    {
      'section': 'Perception',
      'question':
          'On a scale of 1-5, how would you rate the severity of your condition?',
      'key': 'severity',
      'type': 'number'
    },
    {
      'section': 'Perception',
      'question': 'What do you hope to achieve from this visit?',
      'key': 'visitGoals',
      'type': 'text'
    },
    {
      'section': 'Consent',
      'question':
          'Would you like to send this information to your doctor before the visit? (yes/no)',
      'key': 'sendToDoctor',
      'type': 'boolean'
    }
  ];

  Future<void> _saveMessage(String text, bool isUser) async {
    try {
      await _firestoreService.saveChatMessage(text, isUser);
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

  Future<void> _loadPreVisitResponses() async {
    try {
      final medicalData = await _firestoreService.getMedicalData();
      if (medicalData != null && medicalData['preVisitResponses'] != null) {
        setState(() {
          _preVisitResponses =
              Map<String, dynamic>.from(medicalData['preVisitResponses']);
        });
      }
    } catch (e) {
      developer.log('Error loading pre-visit responses: $e');
    }
  }

  Future<void> _savePreVisitResponse(String key, dynamic value) async {
    try {
      _preVisitResponses[key] = value;
      await _firestoreService.saveMedicalData({
        'preVisitResponses': _preVisitResponses,
      });
    } catch (e) {
      developer.log('Error saving pre-visit response: $e');
    }
  }

  void _handlePreVisitResponse(String response) {
    if (_currentQuestionIndex < _preVisitQuestions.length) {
      final currentQuestion = _preVisitQuestions[_currentQuestionIndex];
      _savePreVisitResponse(currentQuestion['key'], response);

      setState(() {
        // Add user's response to UI
        _messages.add(_buildMessage(response, isUser: true));

        // Save the Q&A pair in the correct order
        _saveMessage(
            currentQuestion['question'], false); // Save the question first
        _saveMessage(response, true); // Then save the answer

        _currentQuestionIndex++;

        if (_currentQuestionIndex < _preVisitQuestions.length) {
          // Show next question
          final nextQuestion = _preVisitQuestions[_currentQuestionIndex];
          _messages.add(_buildMessage(nextQuestion['question'], isUser: false));
        } else {
          // Pre-visit questionnaire completed
          _isPreVisitMode = false;
          final completionMessage =
              'Thank you for completing the pre-visit questionnaire. I\'ve saved your responses. How can I help you now?';
          _messages.add(_buildMessage(completionMessage, isUser: false));
          _saveMessage(completionMessage, false);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreVisitResponses();

    // Start with the first pre-visit question
    final welcomeMessage =
        'Hello! I\'m your medical assistant. Before we begin, I\'d like to collect some information about your visit.';
    final firstQuestion = _preVisitQuestions[0]['question'];

    setState(() {
      _messages.add(_buildMessage(welcomeMessage, isUser: false));
      _messages.add(_buildMessage(firstQuestion, isUser: false));
    });

    // Save welcome message and first question
    _saveMessage(welcomeMessage, false);
    _saveMessage(firstQuestion, false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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

    if (_isPreVisitMode) {
      _handlePreVisitResponse(text);
      _textController.clear();
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.add(_buildMessage(text, isUser: true));
      _textController.clear();
    });

    await _saveMessage(text, true);

    try {
      final response = await _aiService.sendTextMessage(text);
      if (response != null) {
        setState(() {
          _messages.add(_buildMessage(response, isUser: false));
        });
        await _saveMessage(response, false);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _isPreVisitMode ? 'Pre-Visit Questionnaire' : 'Medical Assistant',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
                      hintText: _isPreVisitMode
                          ? 'Type your answer...'
                          : 'Type your question...',
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
