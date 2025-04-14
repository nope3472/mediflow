import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medi_flow_new/video_consultation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'chat_consultation.dart';

class ContactDoctorScreen extends StatefulWidget {
  const ContactDoctorScreen({Key? key}) : super(key: key);

  @override
  State<ContactDoctorScreen> createState() => _ContactDoctorScreenState();
}

class _ContactDoctorScreenState extends State<ContactDoctorScreen> {
  Future<void> _saveNotification(
      String consultationType, DateTime dateTime) async {
    try {
      developer
          .log('Saving notification for date: ${dateTime.toIso8601String()}');

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications') ?? '[]';
      developer.log('Current notifications: $notificationsJson');

      final List<dynamic> notifications = jsonDecode(notificationsJson);

      final notification = {
        'type': 'video_consultation',
        'title': 'Video Consultation Booked',
        'doctorName': 'Dr. John Smith', // Default doctor for now
        'specialization': 'General Physician', // Default specialization
        'dateTime': dateTime.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      developer.log('Adding notification: ${jsonEncode(notification)}');
      notifications.insert(0, notification);

      await prefs.setString('notifications', jsonEncode(notifications));
      developer.log('Saved notifications. New count: ${notifications.length}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      developer.log('Error saving notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildConsultationOption({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D9CDB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2D9CDB),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
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
          'Contact Doctor',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildConsultationOption(
            title: 'Video Consultation',
            description: 'Schedule a video call with the doctor',
            icon: Icons.video_call,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoConsultation(),
                ),
              );
            },
          ),
          _buildConsultationOption(
            title: 'Phone Consultation',
            description: 'Schedule a phone call with the doctor',
            icon: Icons.phone,
            onTap: () {
              // TODO: Implement phone consultation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone consultation feature coming soon!'),
                ),
              );
            },
          ),
          _buildConsultationOption(
            title: 'Chat Consultation',
            description: 'Chat with the doctor in real-time',
            icon: Icons.chat,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatConsultation(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
