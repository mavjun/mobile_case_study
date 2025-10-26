import 'package:flutter/material.dart';
import 'request_form.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'config.dart';
import 'all_requests.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String userName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final baseUrl = await Config.baseUrl;
      final response = await http.get(
        Uri.parse("$baseUrl/auth/get_user.php?user_id=${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            userName = data['user']['name'];
            isLoading = false;
          });
        } else {
          setState(() {
            userName = "User";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          userName = "User";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = "User";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeTab(userName: userName),
      const RequestsTab(),
      ProfileTab(
        userId: widget.userId,
        onNameChanged: (newName) {
          setState(() {
            userName = newName;
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Resident Portal'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RequestFormScreen()),
          );
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final String userName;
  const HomeTab({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit your barangay requests easily',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                'Barangay Clearance',
                Icons.description,
                Colors.green,
                context,
              ),
              _buildActionCard(
                'Business Clearance',
                Icons.business,
                Colors.orange,
                context,
              ),
              _buildActionCard(
                'Certificate',
                Icons.verified,
                Colors.purple,
                context,
              ),
              _buildActionCard(
                'Other Request',
                Icons.help_outline,
                Colors.blue,
                context,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Requests
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllRequestsScreen(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 67, 61, 227),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildRequestCard(
            'Barangay Clearance',
            'Submitted: Sep 30, 2025',
            'Pending',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildRequestCard(
            'Business Clearance',
            'Submitted: Sep 28, 2025',
            'Processing',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RequestFormScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    String title,
    String date,
    String status,
    Color statusColor,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(date, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                    ),
                    child: const Text(
                      'Download',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your Requests History', style: TextStyle(fontSize: 20)),
    );
  }
}

class ProfileTab extends StatefulWidget {
  final int userId;
  final Function(String) onNameChanged; // Add this

  const ProfileTab({
    super.key,
    required this.userId,
    required this.onNameChanged,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // User information - will be loaded from API
  String _fullName = 'Loading...';
  String _email = 'Loading...';
  String _phoneNumber = 'Loading...';
  String _address = 'Loading...';
  String _birthDate = 'Loading...';
  bool _isLoading = true;
  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // Controllers for editing
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _birthDateController;

  // Password change controllers
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _birthDateController = TextEditingController();

    // Load user data
    _loadUserData();
  }

  // Function to load user data from API
  Future<void> _loadUserData() async {
    try {
      // Replace with your actual API endpoint
      final baseUrl = await Config.baseUrl;
      final response = await http.get(
        Uri.parse("$baseUrl/auth/get_user.php?user_id=${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _fullName = data['user']['name'] ?? 'No Name';
            _email = data['user']['email'] ?? 'No Email';
            _phoneNumber = data['user']['phone_number'] ?? 'No Phone';
            _address = data['user']['address'] ?? 'No Address';
            _birthDate = data['user']['birth_date'] ?? 'No Birth Date';
            _isLoading = false;
          });

          // Update controllers with loaded data
          _fullNameController.text = _fullName;
          _emailController.text = _email;
          _phoneController.text = _phoneNumber;
          _addressController.text = _address;
          _birthDateController.text = _birthDate;
        } else {
          _showError('Failed to load user data');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Network error: $e');
      // Fallback to demo data
      setState(() {
        _fullName = 'John Doe';
        _email = 'john.doe@email.com';
        _phoneNumber = '+63 912 345 6789';
        _address = '123 Main Street, Barangay 123, City';
        _birthDate = '1990-01-15';
        _isLoading = false;
      });
    }
  }

  // Function to update user profile
  Future<void> _updateProfile() async {
    try {
      final baseUrl = await Config.baseUrl;
      final response = await http.post(
        Uri.parse("$baseUrl/auth/update_profile.php"),

        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId, // pass the current userId
          'name': _fullNameController.text,
          'email': _emailController.text,
          'phone_number': _phoneController.text,
          'address': _addressController.text,
          'birth_date': _birthDateController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _fullName = _fullNameController.text;
            _email = _emailController.text;
            _phoneNumber = _phoneController.text;
            _address = _addressController.text;
            _birthDate = _birthDateController.text;
          });

          // Update Dashboard
          widget.onNameChanged(_fullNameController.text);

          Navigator.pop(context); // close edit modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
        } else {
          _showError(data['error'] ?? 'Failed to update profile');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Network error: $e');
    }
  }

  // Function to change password
  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );

      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    try {
      final baseUrl = await Config.baseUrl;
      final response = await http.post(
        Uri.parse("$baseUrl/auth/change_password.php"),

        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
        }),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Failed to update password'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[100],
                    border: Border.all(color: Colors.blue[700]!, width: 3),
                  ),
                  child: Icon(Icons.person, size: 50, color: Colors.blue[700]),
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        _fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                Text(
                  _email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Personal Information Section
          _buildSectionHeader('Personal Information'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        _buildInfoRow('Full Name', _fullName),
                        const Divider(),
                        _buildInfoRow('Email', _email),
                        const Divider(),
                        _buildInfoRow('Phone Number', _phoneNumber),
                        const Divider(),
                        _buildInfoRow('Address', _address),
                        const Divider(),
                        _buildInfoRow('Birth Date', _birthDate),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _editProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _changePassword,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.blue[700]!),
                  ),
                  icon: Icon(Icons.lock, color: Colors.blue[700]),
                  label: Text(
                    'Change Password',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Account Settings Section
          _buildSectionHeader('Account Settings'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                _buildSettingOption(
                  Icons.notifications,
                  'Push Notifications',
                  'Receive updates about your requests',
                  true,
                  (value) {
                    // Handle notification toggle
                  },
                ),
                const Divider(),
                _buildSettingOption(
                  Icons.email,
                  'Email Notifications',
                  'Get email updates for your requests',
                  true,
                  (value) {
                    // Handle email notification toggle
                  },
                ),
                const Divider(),
                _buildSettingOption(
                  Icons.security,
                  'Two-Factor Authentication',
                  'Extra security for your account',
                  false,
                  (value) {
                    // Handle 2FA toggle
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Logout Button
          Center(
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _showLogoutConfirmation,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.red[300]!),
                ),
                icon: Icon(Icons.logout, color: Colors.red[400]),
                label: Text('Logout', style: TextStyle(color: Colors.red[400])),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[700],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildEditField('Full Name', _fullNameController),
                const SizedBox(height: 16),
                _buildEditField('Email', _emailController),
                const SizedBox(height: 16),
                _buildEditField('Phone Number', _phoneController),
                const SizedBox(height: 16),
                _buildEditField('Address', _addressController, maxLines: 3),
                const SizedBox(height: 16),
                _buildEditField('Birth Date', _birthDateController),
                const SizedBox(height: 24),
                SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  void _changePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom +
                20,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Current Password
                _buildPasswordField(
                  'Current Password',
                  _currentPasswordController,
                  _isCurrentPasswordObscured,
                  () => setModalState(() {
                    _isCurrentPasswordObscured = !_isCurrentPasswordObscured;
                  }),
                ),
                const SizedBox(height: 16),

                // New Password
                _buildPasswordField(
                  'New Password',
                  _newPasswordController,
                  _isNewPasswordObscured,
                  () => setModalState(() {
                    _isNewPasswordObscured = !_isNewPasswordObscured;
                  }),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildPasswordField(
                  'Confirm New Password',
                  _confirmPasswordController,
                  _isConfirmPasswordObscured,
                  () => setModalState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  }),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Update Password'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback toggleVisibility,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog

              // Clear user session info (if using variables)
              // You can also clear SharedPreferences here if implemented

              // Navigate back to Login Screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false, // Remove all previous routes
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
