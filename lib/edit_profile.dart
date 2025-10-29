import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> residentData;
  final Function(Map<String, dynamic>) onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.residentData,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final List<String> _civilStatusOptions = [
    'Single',
    'Married',
    'Widowed',
    'Separated',
  ];
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  String? _selectedCivilStatus;
  String? _selectedGender;
  DateTime? _selectedDate;
  late TextEditingController _barangayNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _occupationController;
  bool _isLoading = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _userId = widget.residentData['user_id'];
    _barangayNameController = TextEditingController(
      text: widget.residentData['barangay_name'] ?? '',
    );
    _firstNameController = TextEditingController(
      text: widget.residentData['first_name'] ?? '',
    );
    _middleNameController = TextEditingController(
      text: widget.residentData['middle_name'] ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.residentData['last_name'] ?? '',
    );
    _dateOfBirthController = TextEditingController(
      text: widget.residentData['date_of_birth'] ?? '',
    );
    _contactNumberController = TextEditingController(
      text: widget.residentData['contact_number'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.residentData['email'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.residentData['address'] ?? '',
    );
    _occupationController = TextEditingController(
      text: widget.residentData['occupation'] ?? '',
    );
    _selectedGender = widget.residentData['gender'];
    _selectedCivilStatus = widget.residentData['civil_status'];

    final dateOfBirth = widget.residentData['date_of_birth'];
    if (dateOfBirth != null && dateOfBirth.isNotEmpty && dateOfBirth != 'N/A') {
      try {
        _selectedDate = DateTime.parse(dateOfBirth);
        _dateOfBirthController.text = _formatDate(_selectedDate!);
      } catch (e) {
        _dateOfBirthController.text = dateOfBirth;
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_isLoading) return;

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _dateOfBirthController.text.isEmpty ||
        _selectedGender == null ||
        _emailController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedCivilStatus == null ||
        _occupationController.text.isEmpty ||
        _barangayNameController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    if (_userId == null) {
      _showError('User ID not found');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseUrl = await Config.baseUrl;

      final response = await http.put(
        Uri.parse("$baseUrl/api/resident-profile/update-profile"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': _userId,
          'first_name': _firstNameController.text,
          'middle_name': _middleNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
          'contact_number': _contactNumberController.text,
          'date_of_birth': _dateOfBirthController.text,
          'gender': _selectedGender!,
          'civil_status': _selectedCivilStatus!,
          'occupation': _occupationController.text,
          'barangay_name': _barangayNameController.text,
          'address': _addressController.text,
        }),
      );

      print('🌐 Update Profile API Response: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final updatedData = {
            'resident_id':
                data['profile']['resident']['resident_id'] ??
                widget.residentData['resident_id'],
            'barangay_name': _barangayNameController.text,
            'first_name': _firstNameController.text,
            'middle_name': _middleNameController.text,
            'last_name': _lastNameController.text,
            'date_of_birth': _dateOfBirthController.text,
            'gender': _selectedGender!,
            'contact_number': _contactNumberController.text,
            'email': _emailController.text,
            'address': _addressController.text,
            'civil_status': _selectedCivilStatus!,
            'occupation': _occupationController.text,
          };

          widget.onProfileUpdated(updatedData);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else {
          _showError(data['error'] ?? 'Failed to update profile');
        }
      } else {
        final errorData = json.decode(response.body);
        _showError(
          errorData['error'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Network error: $e');
      _showError('Network error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, size: 16, color: Colors.grey[600]),
            if (icon != null) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged, {
    IconData? icon,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) Icon(icon, size: 16, color: Colors.grey[600]),
            if (icon != null) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'Select $label',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                ...options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cake, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            const Text(
              'Date of Birth',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _dateOfBirthController,
            readOnly: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'Select Date of Birth',
              hintStyle: TextStyle(color: Colors.grey[400]),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Colors.blue[700],
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            onTap: () => _selectDate(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[700]!, Colors.blue[600]!],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            'Update your personal information',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isLoading)
                      Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          backgroundColor: Colors.white.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Resident ID Card
                  if (widget.residentData['resident_id'] != null &&
                      widget.residentData['resident_id'] != 'N/A')
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue[50]!, Colors.blue[100]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.badge,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resident ID',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.residentData['resident_id'].toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Personal Information Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildFormField(
                          'First Name',
                          _firstNameController,
                          icon: Icons.person,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Middle Name',
                          _middleNameController,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Last Name',
                          _lastNameController,
                          icon: Icons.person,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          'Gender',
                          _selectedGender,
                          _genderOptions,
                          (newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                          icon: Icons.transgender,
                          isRequired: true,
                        ),
                      ],
                    ),
                  ),

                  // Contact Information Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.contact_phone,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildFormField(
                          'Email',
                          _emailController,
                          icon: Icons.email,
                          isRequired: true,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Contact Number',
                          _contactNumberController,
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Address',
                          _addressController,
                          icon: Icons.home,
                          isRequired: true,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  // Additional Information Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.work_outline,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Additional Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          'Civil Status',
                          _selectedCivilStatus,
                          _civilStatusOptions,
                          (newValue) {
                            setState(() {
                              _selectedCivilStatus = newValue;
                            });
                          },
                          icon: Icons.family_restroom,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Occupation',
                          _occupationController,
                          icon: Icons.work,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Barangay Name',
                          _barangayNameController,
                          icon: Icons.location_city,
                          isRequired: true,
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.blue[700]!),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.blue[700]!, Colors.blue[600]!],
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: _isLoading ? null : _updateProfile,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isLoading)
                                      Container(
                                        width: 16,
                                        height: 16,
                                        margin: const EdgeInsets.only(right: 8),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.white),
                                        ),
                                      ),
                                    Icon(
                                      Icons.save,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isLoading ? 'Saving...' : 'Save Changes',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _barangayNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    super.dispose();
  }
}
