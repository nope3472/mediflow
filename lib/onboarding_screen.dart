// onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:medi_flow_new/home_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '', age = '', sex = '', contact = '';
  String medications = '', diseases = '', allergies = '';
  bool consentGiven = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Personal Information",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                onChanged: (val) => name = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                onChanged: (val) => age = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Sex"),
                onChanged: (val) => sex = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Contact"),
                keyboardType: TextInputType.phone,
                onChanged: (val) => contact = val,
              ),
              const SizedBox(height: 20),
              const Text(
                "Health Info",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Regular Medications",
                ),
                onChanged: (val) => medications = val,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Known Diseases/Conditions",
                ),
                onChanged: (val) => diseases = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Allergies"),
                onChanged: (val) => allergies = val,
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                value: consentGiven,
                onChanged: (val) => setState(() => consentGiven = val ?? false),
                title: const Text("I consent to data processing (GDPR)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && consentGiven) {
                    // Save onboarding completion status
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('onboarding_done', true);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeDashboard(userName: name),
                      ),
                    );
                  }
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
