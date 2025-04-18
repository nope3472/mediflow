import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_selection.dart';
import 'doctor_chat.dart';
import 'dart:convert';

class DoctorDashboard extends StatefulWidget {
  final String doctorName;
  final String doctorEmail;
  final String licenseNumber;

  const DoctorDashboard({
    Key? key,
    required this.doctorName,
    required this.doctorEmail,
    required this.licenseNumber,
  }) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 1;
  List<Map<String, dynamic>> _appointments = [];
  Map<String, dynamic> _doctorInfo = {};
  List<Map<String, dynamic>> _connectedPatients = [];
  List<Map<String, dynamic>> _patientReports = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
    _loadAppointments();
    _loadConnectedPatients();
    _loadPatientReports();
  }

  Future<void> _loadDoctorInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _doctorInfo = {
        'email': prefs.getString('doctor_email') ?? widget.doctorEmail,
        'name': prefs.getString('doctor_name') ?? widget.doctorName,
        'license': prefs.getString('doctor_license') ?? widget.licenseNumber,
      };
    });
  }

  void _loadConnectedPatients() {
    // Dummy data for connected patients
    setState(() {
      _connectedPatients = [
        {
          'id': '1',
          'name': 'John Doe',
          'age': 35,
          'gender': 'Male',
          'lastVisit': '2024-03-15',
          'status': 'Active',
        },
        {
          'id': '2',
          'name': 'Jane Smith',
          'age': 28,
          'gender': 'Female',
          'lastVisit': '2024-03-18',
          'status': 'Active',
        },
        {
          'id': '3',
          'name': 'Robert Johnson',
          'age': 45,
          'gender': 'Male',
          'lastVisit': '2024-03-10',
          'status': 'Inactive',
        },
      ];
    });
  }

  void _loadPatientReports() {
    // Dummy data for patient reports
    setState(() {
      _patientReports = [
        {
          'patientName': 'John Doe',
          'reportType': 'Blood Test',
          'date': '2024-03-15',
          'status': 'Normal',
          'details': 'All parameters within normal range',
        },
        {
          'patientName': 'Jane Smith',
          'reportType': 'X-Ray',
          'date': '2024-03-18',
          'status': 'Review Required',
          'details': 'Minor fracture detected in right arm',
        },
      ];
    });
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _appointments = [
        {
          'id': '1',
          'patientName': 'John Doe',
          'time': '10:00 AM',
          'date': '2024-03-20',
          'type': 'Video Consultation',
          'status': 'Pending',
        },
        {
          'id': '2',
          'patientName': 'Jane Smith',
          'time': '11:30 AM',
          'date': '2024-03-20',
          'type': 'Chat Consultation',
          'status': 'Pending',
        },
      ];
    });
  }

  Future<void> _handleAppointmentAction(
      String appointmentId, bool isAccept) async {
    if (!isAccept) {
      // Show reason dialog for declined appointments
      final reasonController = TextEditingController();
      final hasReason = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reason for Declining'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter reason for declining the appointment',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, reasonController.text.isNotEmpty),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (hasReason != true) return; // User cancelled or didn't enter reason
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getString('appointments') ?? '[]';
      final List<dynamic> appointments = jsonDecode(appointmentsJson);

      // Find and update the appointment in SharedPreferences
      final appointmentIndex =
          appointments.indexWhere((a) => a['id'] == appointmentId);
      if (appointmentIndex != -1) {
        appointments[appointmentIndex]['status'] =
            isAccept ? 'Confirmed' : 'Declined';
        await prefs.setString('appointments', jsonEncode(appointments));
      }

      // Update local state
      setState(() {
        final localIndex =
            _appointments.indexWhere((a) => a['id'] == appointmentId);
        if (localIndex != -1) {
          _appointments[localIndex]['status'] =
              isAccept ? 'Confirmed' : 'Declined';
        }
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAccept
                ? 'Appointment confirmed. Patient will be notified.'
                : 'Appointment declined. Patient will be notified.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileSection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header with Picture
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2D9CDB),
                  child: Text(
                    _doctorInfo['name']?.substring(0, 1).toUpperCase() ?? 'D',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _doctorInfo['name'] ?? 'Doctor Name',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'License: ${_doctorInfo['license'] ?? 'Not set'}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement profile picture upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile picture upload coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Change Profile Picture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D9CDB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Professional Information Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Professional Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          // TODO: Implement edit professional info
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Edit professional info coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProfileItem(
                    icon: Icons.medical_services_outlined,
                    label: 'Specialization',
                    value: 'General Medicine',
                  ),
                  const Divider(),
                  _buildProfileItem(
                    icon: Icons.work_outline,
                    label: 'Experience',
                    value: '10 years',
                  ),
                  const Divider(),
                  _buildProfileItem(
                    icon: Icons.school_outlined,
                    label: 'Education',
                    value: 'MD, Harvard Medical School',
                  ),
                  const Divider(),
                  _buildProfileItem(
                    icon: Icons.location_on_outlined,
                    label: 'Clinic Location',
                    value: '123 Medical Center, New York',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact Information Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Contact Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          // TODO: Implement edit contact info
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit contact info coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProfileItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _doctorInfo['email'] ?? 'Not set',
                  ),
                  const Divider(),
                  _buildProfileItem(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: '+1 (555) 123-4567',
                  ),
                  const Divider(),
                  _buildProfileItem(
                    icon: Icons.language_outlined,
                    label: 'Languages',
                    value: 'English, Spanish, French',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Availability Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Availability',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          // TODO: Implement edit availability
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit availability coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAvailabilityDay(
                    day: 'Monday',
                    time: '9:00 AM - 5:00 PM',
                  ),
                  const Divider(),
                  _buildAvailabilityDay(
                    day: 'Tuesday',
                    time: '9:00 AM - 5:00 PM',
                  ),
                  const Divider(),
                  _buildAvailabilityDay(
                    day: 'Wednesday',
                    time: '9:00 AM - 5:00 PM',
                  ),
                  const Divider(),
                  _buildAvailabilityDay(
                    day: 'Thursday',
                    time: '9:00 AM - 5:00 PM',
                  ),
                  const Divider(),
                  _buildAvailabilityDay(
                    day: 'Friday',
                    time: '9:00 AM - 3:00 PM',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAvailabilityDay({
    required String day,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2D9CDB),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedPatients() {
    return ListView.builder(
      itemCount: _connectedPatients.length,
      itemBuilder: (context, index) {
        final patient = _connectedPatients[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2D9CDB),
              child: Text(
                patient['name'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              patient['name'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Age: ${patient['age']} | ${patient['gender']}',
              style: GoogleFonts.poppins(),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: patient['status'] == 'Active'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                patient['status'],
                style: GoogleFonts.poppins(
                  color: patient['status'] == 'Active'
                      ? Colors.green
                      : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {
              // Show patient details
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(patient['name']),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: ${patient['age']}'),
                      Text('Gender: ${patient['gender']}'),
                      Text('Last Visit: ${patient['lastVisit']}'),
                      Text('Status: ${patient['status']}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChatSection() {
    return ListView.builder(
      itemCount: _connectedPatients.length,
      itemBuilder: (context, index) {
        final patient = _connectedPatients[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2D9CDB),
              child: Text(
                patient['name'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              patient['name'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Last message: Today, 10:30 AM',
              style: GoogleFonts.poppins(),
            ),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorChatScreen(
                    patientName: patient['name'],
                    patientId: patient['id'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildReportsSection() {
    return ListView.builder(
      itemCount: _patientReports.length,
      itemBuilder: (context, index) {
        final report = _patientReports[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              report['patientName'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${report['reportType']} - ${report['date']}',
              style: GoogleFonts.poppins(),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: report['status'] == 'Normal'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report['status'],
                style: GoogleFonts.poppins(
                  color: report['status'] == 'Normal'
                      ? Colors.green
                      : Colors.orange,
                  fontSize: 12,
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details:',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report['details'],
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsSection() {
    return ListView.builder(
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment['patientName'],
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${appointment['time']} - ${appointment['date']}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.video_call,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment['type'],
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (appointment['status'] == 'Pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            _handleAppointmentAction(appointment['id'], false),
                        child: Text(
                          'Decline',
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _handleAppointmentAction(appointment['id'], true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D9CDB),
                        ),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Confirmed',
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctor_email');
    await prefs.remove('doctor_name');
    await prefs.remove('doctor_license');
    await prefs.remove('is_doctor');
    await prefs.remove('doctor_password');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const RoleSelectionScreen(),
        ),
        (route) => false, // This removes all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back to role selection
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            'Doctor Dashboard',
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
              icon: const Icon(Icons.logout, color: Colors.black54),
              onPressed: _signOut,
            ),
          ],
        ),
        body: _selectedIndex == 0
            ? _buildProfileSection()
            : _selectedIndex == 1
                ? _buildConnectedPatients()
                : _selectedIndex == 2
                    ? _buildChatSection()
                    : _selectedIndex == 3
                        ? _buildReportsSection()
                        : _buildAppointmentsSection(),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF2D9CDB),
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
