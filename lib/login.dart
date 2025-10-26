import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard.dart'; // Import your dashboard file
import 'register.dart';
import 'config.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Function to handle login with database
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final baseUrlString = await Config.baseUrl; // Await the baseUrl

        final response = await http.post(
          Uri.parse("$baseUrlString/auth/login.php"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": _emailController.text.trim(),
            "password": _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            final int userId = data['user']['id'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Login successful! Welcome ${data['user']['name']}',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
              ),
            );

            // Navigate to Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(userId: userId),
              ),
            );
          } else {
            _showError(data['error'] ?? "Login failed");
          }
        } else {
          _showError("Server error: ${response.statusCode}");
        }
      } catch (e) {
        _showError("Cannot connect to server: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );
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
                // Logo/Title
                _buildLogo(),
                SizedBox(height: 48.0),

                // Login Form
                _buildLoginForm(),
                SizedBox(height: 24.0),

                // Login Button
                _buildLoginButton(),
                SizedBox(height: 24.0),

                // Sign up link
                _buildSignUpLink(),
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
          child: Icon(Icons.person, size: 40, color: Colors.blue.shade600),
        ),
        SizedBox(height: 16.0),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),

          // Password Field
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
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _showForgotPasswordDialog();
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.blue.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistrationPage()),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: Text(
          'Please contact the barangay administration to reset your password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
