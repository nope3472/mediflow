import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medi_flow_new/services/firestore_service.dart';

class MedicalSummary extends StatefulWidget {
  const MedicalSummary({Key? key}) : super(key: key);

  @override
  State<MedicalSummary> createState() => _MedicalSummaryState();
}

class _MedicalSummaryState extends State<MedicalSummary> {
  bool _isEditing = false;
  final FirestoreService _firestoreService = FirestoreService();

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _conditionsController = TextEditingController();

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadMedicalData();
    _heightController.addListener(_calculateBMI);
    _weightController.addListener(_calculateBMI);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _bloodGroupController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    if (_heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      try {
        final height =
            double.parse(_heightController.text) / 100; // convert cm to m
        final weight = double.parse(_weightController.text);
        final bmi = (weight / (height * height)).toStringAsFixed(1);
        _bmiController.text = bmi;
      } catch (e) {
        _bmiController.text = '';
      }
    } else {
      _bmiController.text = '';
    }
  }

  Future<void> _loadMedicalData() async {
    try {
      final medicalData = await _firestoreService.getMedicalData();
      if (medicalData != null) {
        setState(() {
          _nameController.text = medicalData['name'] ?? '';
          _ageController.text = medicalData['age'] ?? '';
          _genderController.text = medicalData['gender'] ?? '';
          _bloodGroupController.text = medicalData['bloodGroup'] ?? '';
          _heightController.text = medicalData['height'] ?? '';
          _weightController.text = medicalData['weight'] ?? '';
          _bmiController.text = medicalData['bmi'] ?? '';
          _allergiesController.text = medicalData['allergies'] ?? '';
          _medicationsController.text = medicalData['medications'] ?? '';
          _conditionsController.text = medicalData['conditions'] ?? '';
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveMedicalData() async {
    try {
      final medicalData = {
        'name': _nameController.text,
        'age': _ageController.text,
        'gender': _genderController.text,
        'bloodGroup': _bloodGroupController.text,
        'height': _heightController.text,
        'weight': _weightController.text,
        'bmi': _bmiController.text,
        'allergies': _allergiesController.text,
        'medications': _medicationsController.text,
        'conditions': _conditionsController.text,
      };

      await _firestoreService.saveMedicalData(medicalData);
      setState(() => _isEditing = false);
    } catch (e) {
      // Handle error
    }
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required dynamic controller,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    bool isDropdown = false,
    List<String>? items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          if (_isEditing && !isDropdown)
            TextFormField(
              controller: controller as TextEditingController,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'Please enter $label';
                }
                return null;
              },
            )
          else if (_isEditing && isDropdown)
            DropdownButtonFormField<String>(
              value: controller as String?,
              decoration: InputDecoration(
                hintText: 'Select $label',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: items?.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  if (label == 'Gender') {
                    _genderController.text = value ?? '';
                  } else if (label == 'Blood Group') {
                    _bloodGroupController.text = value ?? '';
                  }
                });
              },
              validator: isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select $label';
                      }
                      return null;
                    }
                  : null,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isDropdown
                    ? (controller as String? ?? 'Not set')
                    : (controller.text.isEmpty ? 'Not set' : controller.text),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: (isDropdown
                          ? controller == null
                          : controller.text.isEmpty)
                      ? Colors.black38
                      : Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Health Profile',
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
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: const Color(0xFF2D9CDB),
            ),
            onPressed: () {
              if (_isEditing) {
                _saveMedicalData();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: Form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information
              _buildSectionCard(
                title: 'Personal Information',
                children: [
                  _buildInfoRow(
                    label: 'Full Name',
                    controller: _nameController,
                  ),
                  _buildInfoRow(
                    label: 'Age',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInfoRow(
                    label: 'Gender',
                    controller: _genderController,
                    isDropdown: true,
                    items: _genders,
                  ),
                  _buildInfoRow(
                    label: 'Blood Group',
                    controller: _bloodGroupController,
                    isDropdown: true,
                    items: _bloodGroups,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Physical Information
              _buildSectionCard(
                title: 'Physical Information',
                children: [
                  _buildInfoRow(
                    label: 'Height (cm)',
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInfoRow(
                    label: 'Weight (kg)',
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInfoRow(
                    label: 'BMI',
                    controller: _bmiController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Medical History
              _buildSectionCard(
                title: 'Medical History',
                children: [
                  _buildInfoRow(
                    label: 'Allergies',
                    controller: _allergiesController,
                    isRequired: false,
                  ),
                  _buildInfoRow(
                    label: 'Current Medications',
                    controller: _medicationsController,
                    isRequired: false,
                  ),
                  _buildInfoRow(
                    label: 'Medical Conditions',
                    controller: _conditionsController,
                    isRequired: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
