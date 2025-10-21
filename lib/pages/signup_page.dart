// filename: pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../model/user.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'customer'; // default

  final _formKey = GlobalKey<FormState>();

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<User>('users');
    final username = _usernameController.text.trim();
    final passwordHash =
        sha256.convert(utf8.encode(_passwordController.text)).toString();

    if (box.values.any((u) => u.username == username)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Username exists')));
      return;
    }

    await box.add(User(username: username, passwordHash: passwordHash, role: _role));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter username' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _role = v);
                },
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _signup, child: const Text('Signup')),
            ],
          ),
        ),
      ),
    );
  }
}
