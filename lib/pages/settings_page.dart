import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../model/user.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  final String username;

  const SettingsPage({super.key, required this.username});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late Box<User> userBox;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    try {
      currentUser = userBox.values.firstWhere((u) => u.username == widget.username);
    } catch (e) {
      currentUser = null;
    }
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate() || currentUser == null) return;

    final newPasswordHash = sha256.convert(utf8.encode(_passwordController.text)).toString();
    
    // Update and Save
    currentUser!.passwordHash = newPasswordHash;
    currentUser!.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );

    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text("User profile not found."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Icon(Icons.security, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          Text("Settings for ${widget.username}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters required' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _changePassword, 
                        child: const Text('UPDATE PASSWORD')
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}