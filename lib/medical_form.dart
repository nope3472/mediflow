import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medi_flow_new/medical_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_dashboard.dart';

class MedicalForm extends StatefulWidget {
  final String userName;

  const MedicalForm({super.key, required this.userName});

  @override
  State<MedicalForm> createState() => _MedicalFormState();
}

class _MedicalFormState extends State<MedicalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bmiController = TextEditingController();
  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _hasAllergies = false;
  bool _hasChronicConditions = false;
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  bool _isLoading = false;

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

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _heightController.addListener(_calculateBMI);
    _weightController.addListener(_calculateBMI);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bmiController.dispose();
    _allergiesController.dispose();
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

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _nameController.text = widget.userName;
        _ageController.text = prefs.getString('medical_age') ?? '';
        _selectedGender = prefs.getString('medical_gender');
        _selectedBloodGroup = prefs.getString('medical_blood_group');
        _heightController.text = prefs.getString('medical_height') ?? '';
        _weightController.text = prefs.getString('medical_weight') ?? '';
        _bmiController.text = prefs.getString('medical_bmi') ?? '';

        final allergies = prefs.getString('medical_allergies') ?? '';
        _hasAllergies = allergies != 'None' && allergies.isNotEmpty;
        _allergiesController.text = _hasAllergies ? allergies : '';

        final conditions = prefs.getString('medical_conditions') ?? '';
        _hasChronicConditions = conditions != 'None' && conditions.isNotEmpty;
        _conditionsController.text = _hasChronicConditions ? conditions : '';
      });
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save all form data
      await prefs.setString('medical_name', _nameController.text);
      await prefs.setString('medical_age', _ageController.text);
      await prefs.setString('medical_gender', _selectedGender ?? '');
      await prefs.setString('medical_blood_group', _selectedBloodGroup ?? '');
      await prefs.setString('medical_height', _heightController.text);
      await prefs.setString('medical_weight', _weightController.text);
      await prefs.setString('medical_bmi', _bmiController.text);

      // Save medical history
      await prefs.setString('medical_allergies',
          _hasAllergies ? _allergiesController.text : 'None');
      await prefs.setString('medical_conditions',
          _hasChronicConditions ? _conditionsController.text : 'None');
      await prefs.setBool('hasSubmittedForm', true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical form submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MedicalSummary()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting form: $e'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Medical Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _ageController,
                label: 'Age',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: _selectedGender,
                label: 'Gender',
                icon: Icons.person_outline,
                items: ['Male', 'Female', 'Other'],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Physical Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid height';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid weight';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: _selectedBloodGroup,
                label: 'Blood Group',
                icon: Icons.bloodtype_outlined,
                items: _bloodGroups,
                onChanged: (value) {
                  setState(() => _selectedBloodGroup = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your blood group';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Medical History',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Do you have any allergies?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                value: _hasAllergies,
                onChanged: (value) {
                  setState(() => _hasAllergies = value);
                },
                activeColor: const Color(0xFF2D9CDB),
              ),
              if (_hasAllergies) ...[
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _allergiesController,
                  label: 'List your allergies',
                  icon: Icons.warning_amber_outlined,
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Do you have any chronic conditions?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                value: _hasChronicConditions,
                onChanged: (value) {
                  setState(() => _hasChronicConditions = value);
                },
                activeColor: const Color(0xFF2D9CDB),
              ),
              if (_hasChronicConditions) ...[
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _conditionsController,
                  label: 'List your conditions',
                  icon: Icons.medical_services_outlined,
                  maxLines: 3,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D9CDB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2D9CDB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D9CDB)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2D9CDB)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D9CDB)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((String item) {
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
      onChanged: onChanged,
      validator: validator,
    );
  }
}
