import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../model/user.dart';

class AuthService {
  final Box<User> _userBox = Hive.box<User>('users');

  /// Login Function
  User? login(String username, String password) {
    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    try {
      return _userBox.values.firstWhere(
        (u) => u.username == username && u.passwordHash == passwordHash
      );
    } catch (e) {
      return null;
    }
  }

  /// Signup Function - Updated to accept profile details
  Future<bool> signup(
    String username, 
    String password, 
    String role, {
    // These are the new named parameters causing your error
    required String email,
    required String phone,
    required String age,
    required String location,
  }) async {
    
    // Check if username exists
    if (_userBox.values.any((u) => u.username == username)) {
      return false; 
    }

    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    
    // Create User with new fields
    final newUser = User(
      username: username, 
      passwordHash: passwordHash, 
      role: role,
      email: email,
      phone: phone,
      age: age,
      location: location,
    );
    
    await _userBox.add(newUser);
    return true;
  }
}