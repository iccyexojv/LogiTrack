import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  // Controllers
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  final String _role = 'customer';

  @override
  void initState() {
    super.initState();
    _phoneCtrl.text = "+977"; // DEFAULT PREFIX
    _phoneCtrl.addListener(() {
      // Prevent removing +977
      if (!_phoneCtrl.text.startsWith("+977")) {
        _phoneCtrl.text = "+977";
        _phoneCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: _phoneCtrl.text.length));
      }
    });
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final success = await _authService.signup(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
      _role,
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      age: _ageCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Username already exists'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Welcome aboard! Please login.'),
            backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Expanded(child: Divider(color: Colors.deepPurple, thickness: 0.5)),
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Join LogiTrack'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_outlined,
                    size: 50, color: Colors.deepPurple),
                const SizedBox(height: 10),
                const Text(
                  "Create Customer Profile",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "Start receiving parcels today",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // SECTION 1
                _buildSectionHeader("Login Credentials", Icons.vpn_key),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: _inputDecor('Username', Icons.person),
                  validator: (v) => v!.length < 3 ? 'Min 3 chars' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: _inputDecor('Password', Icons.lock),
                  validator: (v) =>
                      (v == null || v.length < 8) ? 'Min 8 characters' : null,
                ),

                const SizedBox(height: 20),

                // SECTION 2
                _buildSectionHeader("Shipping Details", Icons.local_shipping),

                // EMAIL VALIDATION
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecor('Email Address', Icons.email),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(v)) {
                      return 'Enter valid Gmail (example@gmail.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // PHONE VALIDATION
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecor('Phone Number', Icons.phone),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!RegExp(r'^\+977(98|97)\d{8}$').hasMatch(v)) {
                      return 'Format: +97798XXXXXXXX';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    // AGE
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecor('Age', Icons.cake),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Req';
                          final age = int.tryParse(v);
                          if (age == null) return 'Number only';
                          if (age < 16) return 'Must be 16+';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _locationCtrl,
                        decoration:
                            _inputDecor('City / Location', Icons.location_on),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6750A4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: Colors.deepPurple.withOpacity(0.4),
                    ),
                    onPressed: _isLoading ? null : _signup,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Login"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
