import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../model/user.dart';

class AdminCreateUserPage extends StatefulWidget {
  const AdminCreateUserPage({super.key});

  @override
  State<AdminCreateUserPage> createState() => _AdminCreateUserPageState();
}

class _AdminCreateUserPageState extends State<AdminCreateUserPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: "+977"); // 👈 Default value
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  final String _role = 'customer';

  // ensure cursor stays at end on first load
  @override
  void initState() {
    super.initState();
    _phoneCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneCtrl.text.length),
    );
  }

  void _createUser() {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<User>('users');
    final username = _usernameCtrl.text.trim();

    if (box.values.any((u) => u.username == username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User '$username' already exists!"), backgroundColor: Colors.red),
      );
      return;
    }

    final passwordHash = sha256.convert(utf8.encode(_passwordCtrl.text)).toString();

    final newUser = User(
      username: username,
      passwordHash: passwordHash,
      role: _role,
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      age: _ageCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
    );

    box.add(newUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Success! Customer '$username' created."), backgroundColor: Colors.green),
    );

    // Clear fields except phone (reset to +977)
    _usernameCtrl.clear();
    _passwordCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.text = "+977"; // reset default
    _ageCtrl.clear();
    _locationCtrl.clear();

    _phoneCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneCtrl.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Customer")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) =>
                    (v == null || v.length < 8) ? "Min 8 characters" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final emailRegex =
                      RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                  if (!emailRegex.hasMatch(v)) {
                    return "Enter valid Gmail (example@gmail.com)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // PHONE WITH DEFAULT +977
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (+97798...)'),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";

                  final phoneRegex = RegExp(r'^\+977(98|97)\d{8}$');
                  if (!phoneRegex.hasMatch(v)) {
                    return "Format: +97798XXXXXXXX";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageCtrl,
                      decoration: const InputDecoration(labelText: 'Age'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        final num? age = int.tryParse(v);
                        if (age == null) return "Numbers only";
                        if (age < 16) return "Must be 16+";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6750A4),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("CREATE CUSTOMER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
