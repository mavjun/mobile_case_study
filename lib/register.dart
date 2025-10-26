import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'login.dart';
import 'config.dart'; // ✅ Import your Config file
import 'dart:ui';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _barangayYearsController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  File? _validIdImage;
  String? _validIdFileName;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickValidId() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _validIdImage = File(pickedFile.path);
        _validIdFileName = pickedFile.name; // ✅ Keep original filename
      });
    }
  }

  void _showValidIdPreview() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Preview",
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Dialog(
              backgroundColor: Colors.white, // clean white background
              insetPadding: EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6, // subtle shadow for depth
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Valid ID Preview',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        SizedBox(height: 12),
                        Divider(thickness: 1.2, color: Colors.grey.shade300),
                        SizedBox(height: 12),
                        _validIdImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  _validIdImage!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'No file selected',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickValidId,
                              icon: Icon(
                                Icons.change_circle_outlined,
                                color: Colors.white,
                              ),
                              label: Text('Change ID'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade400,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 4,
                              ),
                            ),
                            SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey.shade700,
                              ),
                              label: Text(
                                'Close',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }

  /// ✅ Updated registration function
  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_validIdImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload a valid ID image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final baseUrl = await Config.baseUrl;
        final url = Uri.parse("$baseUrl/auth/register.php");

        var request = http.MultipartRequest('POST', url)
          ..fields['name'] =
              "${_firstNameController.text} ${_lastNameController.text}"
          ..fields['email'] = _emailController.text
          ..fields['password'] = _passwordController.text
          ..fields['phone_number'] = _phoneController.text
          ..fields['address'] = _addressController.text
          ..fields['barangay_years'] = _barangayYearsController.text;

        request.files.add(
          await http.MultipartFile.fromPath('valid_id', _validIdImage!.path),
        );

        var response = await request.send();
        var responseData = jsonDecode(await response.stream.bytesToString());

        setState(() {
          _isLoading = false;
        });

        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['error'] ?? 'Registration failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                SizedBox(height: 32.0),
                _buildRegistrationForm(),
                SizedBox(height: 24.0),
                _buildRegisterButton(),
                SizedBox(height: 24.0),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_add, size: 40, color: Colors.blue.shade600),
        ),
        SizedBox(height: 16.0),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          'Sign up to get started',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter first name'
                      : null,
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter last name' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter your email';
              if (!value.contains('@')) return 'Enter valid email';
              return null;
            },
          ),
          SizedBox(height: 16.0),

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter phone number';
              if (value.length < 10) return 'Invalid phone number';
              return null;
            },
          ),
          SizedBox(height: 16.0),

          // Address
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 1,
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter your address' : null,
          ),
          SizedBox(height: 16.0),

          // Barangay Residency Years
          TextFormField(
            controller: _barangayYearsController,
            decoration: InputDecoration(
              labelText: 'Barangay Resident (Years)',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Enter years of residency';
              final years = int.tryParse(value);
              if (years == null || years <= 0) return 'Enter valid number';
              return null;
            },
          ),
          SizedBox(height: 16.0),
          // Valid ID Upload
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Valid ID',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickValidId,
                      icon: Icon(Icons.upload_file, color: Colors.white),
                      label: Text('Upload ID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400, // lighter blue
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        shadowColor: Colors.blue.shade200,
                        elevation: 4,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  if (_validIdImage != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showValidIdPreview,
                        icon: Icon(Icons.visibility, color: Colors.white),
                        label: Text('Preview'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.orange.shade300, // softer orange
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          shadowColor: Colors.orange.shade200,
                          elevation: 4,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8),
              // Dynamically show file name
              Text(
                _validIdImage != null
                    ? 'Selected File: $_validIdFileName'
                    : 'No file selected',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),

          SizedBox(height: 16.0),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter your password';
              if (value.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),
          SizedBox(height: 16.0),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please confirm your password';
              if (value != _passwordController.text)
                return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
            );
          },
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _barangayYearsController.dispose();
    super.dispose();
  }
}
