import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthSummaryScreen extends StatelessWidget {
  const HealthSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Summary'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _loadMedicalData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            final medicalData = snapshot.data!; // Non-nullable access
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Height: ${medicalData['height']} cm'),
                  Text('Weight: ${medicalData['weight']} kg'),
                  Text('Allergies: ${medicalData['allergies']}'),
                  Text('Medical History: ${medicalData['medicalHistory']}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, String>> _loadMedicalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'height': prefs.getString('height') ?? 'N/A',
      'weight': prefs.getString('weight') ?? 'N/A',
      'allergies': prefs.getString('allergies') ?? 'N/A',
      'medicalHistory': prefs.getString('medicalHistory') ?? 'N/A',
    };
  }
}
