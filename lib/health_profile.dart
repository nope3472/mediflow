import 'package:flutter/material.dart';

class HealthProfileScreen extends StatelessWidget {
  const HealthProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Profile"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Personal Information
            _buildSectionTitle("Personal Information", onEdit: () {
              // Edit personal info
            }),
            const ListTile(
              title: Text("John Doe"),
              subtitle: Text("Age: 32 • Blood Type: B+"),
              leading: Icon(Icons.person, color: Colors.teal),
            ),
            const Divider(),

            // Medical History Timeline
            _buildSectionTitle("Medical History", onEdit: () {
              // Edit timeline
            }),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _TimelineCard(
                      date: "Jan 2023", detail: "Appendectomy Surgery"),
                  _TimelineCard(
                      date: "Oct 2022", detail: "Flu Vaccination"),
                  _TimelineCard(
                      date: "Jul 2022", detail: "Covid-19 Booster Dose"),
                ],
              ),
            ),
            const Divider(),

            // Current Medications
            _buildSectionTitle("Current Medications", onEdit: () {
              // Edit medications
            }),
            const _ItemListTile(
              title: "Metformin",
              subtitle: "500mg • Twice a day",
            ),
            const _ItemListTile(
              title: "Lisinopril",
              subtitle: "10mg • Once a day",
            ),
            const Divider(),

            // Chronic Conditions
            _buildSectionTitle("Chronic Conditions", onEdit: () {
              // Edit conditions
            }),
            const _ItemListTile(
              title: "Type 2 Diabetes",
              subtitle: "Diagnosed: 2018",
            ),
            const _ItemListTile(
              title: "Hypertension",
              subtitle: "Diagnosed: 2020",
            ),
            const Divider(),

            // Allergies
            _buildSectionTitle("Allergies", onEdit: () {
              // Edit allergies
            }),
            const _ItemListTile(
              title: "Peanuts",
              subtitle: "Severe reaction",
            ),
            const _ItemListTile(
              title: "Penicillin",
              subtitle: "Mild skin rash",
            ),
            const Divider(),

            // Recent Test Results
            _buildSectionTitle("Recent Test Results", onEdit: () {
              // Edit test results
            }),
            const _ItemListTile(
              title: "Blood Sugar (Fasting)",
              subtitle: "110 mg/dL • Jan 2024",
            ),
            const _ItemListTile(
              title: "Cholesterol",
              subtitle: "190 mg/dL • Jan 2024",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required VoidCallback onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.teal),
            onPressed: onEdit,
          )
        ],
      ),
    );
  }
}

// Custom widget for horizontal timeline cards
class _TimelineCard extends StatelessWidget {
  final String date;
  final String detail;

  const _TimelineCard({
    required this.date,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(date,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(detail,
                style: const TextStyle(fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// Custom widget for list tiles
class _ItemListTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ItemListTile({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      leading: const Icon(Icons.medical_services_outlined, color: Colors.teal),
    );
  }
}
