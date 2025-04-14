import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medi_flow_new/login.dart';
import 'package:medi_flow_new/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medi_flow_new/home_dashboard.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Gemini
  Gemini.init(
    apiKey: "AIzaSyCcrDqdZsv-aExddRmxENSgCE8lBundBsA",
  ); // Replace with your actual API key
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _startScreen = const LoginScreen());
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (onboardingDone) {
      setState(
        () =>
            _startScreen = HomeDashboard(userName: user.displayName ?? 'User'),
      );
    } else {
      setState(() => _startScreen = const OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_startScreen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return _startScreen!;
    }
  }
}
