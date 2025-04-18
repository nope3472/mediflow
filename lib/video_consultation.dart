import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

class VideoConsultation extends StatefulWidget {
  const VideoConsultation({super.key});

  @override
  State<VideoConsultation> createState() => _VideoConsultationState();
}

class _VideoConsultationState extends State<VideoConsultation> {
  late SharedPreferences _prefs;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTime;
  bool _isLoading = false;
  bool _isPrefsInitialized = false;

  // Available time slots (in 24-hour format)
  final List<String> _allTimeSlots = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
  ];

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPrefsInitialized = true;
    });
  }

  List<String> _getAvailableTimeSlots() {
    if (!_isPrefsInitialized) return [];

    final bookedSlots = _prefs.getStringList('booked_slots') ?? [];
    final today = DateTime.now();

    // Filter out past time slots for today
    if (_selectedDay.year == today.year &&
        _selectedDay.month == today.month &&
        _selectedDay.day == today.day) {
      final currentTime = DateTime.now();
      return _allTimeSlots.where((slot) {
        final slotTime = slot.split(':');
        final slotDateTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          int.parse(slotTime[0]),
          int.parse(slotTime[1]),
        );
        return !bookedSlots
                .contains('${_selectedDay.toIso8601String()}|$slot') &&
            slotDateTime.isAfter(currentTime);
      }).toList();
    }

    // For future dates, only filter out booked slots
    return _allTimeSlots
        .where((slot) =>
            !bookedSlots.contains('${_selectedDay.toIso8601String()}|$slot'))
        .toList();
  }

  Future<void> _bookAppointment() async {
    if (_selectedTime == null) return;

    setState(() => _isLoading = true);

    try {
      final bookedSlots = _prefs.getStringList('booked_slots') ?? [];
      bookedSlots.add('${_selectedDay.toIso8601String()}|$_selectedTime');
      await _prefs.setStringList('booked_slots', bookedSlots);

      // Save the appointment notification
      final notificationsJson = _prefs.getString('notifications') ?? '[]';
      final List<dynamic> notifications = jsonDecode(notificationsJson);

      final notification = {
        'type': 'video_consultation',
        'title': 'Video Consultation Booked',
        'doctorName': 'Dr. Sarah Johnson',
        'specialization': 'General Physician',
        'dateTime': '${_selectedDay.toIso8601String()}|$_selectedTime',
        'createdAt': DateTime.now().toIso8601String(),
      };

      notifications.insert(0, notification);
      await _prefs.setString('notifications', jsonEncode(notifications));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment booked for ${DateFormat('MMM d, y').format(_selectedDay)} at $_selectedTime. You will be notified when the doctor confirms.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Create a DateTime object for the selected date and time
        final slotTime = _selectedTime!.split(':');
        final selectedDateTime = DateTime(
          _selectedDay.year,
          _selectedDay.month,
          _selectedDay.day,
          int.parse(slotTime[0]),
          int.parse(slotTime[1]),
        );
        Navigator.pop(context, selectedDateTime);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableSlots = _getAvailableTimeSlots();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Video Consultation',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: !_isPrefsInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2D9CDB).withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF2D9CDB),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. Sarah Johnson',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'General Physician',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.8 (120 reviews)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Date',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedTime = null;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF2D9CDB),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF2D9CDB).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Available Time Slots',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (availableSlots.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No slots available for this date',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: availableSlots.length,
                      itemBuilder: (context, index) {
                        final slot = availableSlots[index];
                        final isSelected = _selectedTime == slot;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTime = slot;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2D9CDB)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2D9CDB)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                slot,
                                style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedTime == null || _isLoading
                          ? null
                          : _bookAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D9CDB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Book Appointment',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
