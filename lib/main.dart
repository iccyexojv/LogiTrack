import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Models
import 'model/user.dart';
import 'model/parcel.dart';

// Pages
import 'pages/login_page.dart';
import 'pages/admin_home.dart';
import 'pages/customer_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Hive (The Database)
  await Hive.initFlutter();

  // 2. Register Adapters (So Hive understands your Objects)
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ParcelAdapter());
  Hive.registerAdapter(TrackingEventAdapter());

  // 3. Open Persistent Boxes (Like SQL Tables)
  // These boxes load data from the device storage immediately
  final userBox = await Hive.openBox<User>('users');
  await Hive.openBox<Parcel>('parcels');
  
  // 4. Open a "Session" Box for Auto-Login
  final sessionBox = await Hive.openBox('session');

  // 5. Seed Default Admin (If database is empty)
  if (!userBox.values.any((u) => u.username == 'admin')) {
    final adminPass = sha256.convert(utf8.encode('admin123')).toString();
    userBox.add(User(
      username: 'admin', 
      passwordHash: adminPass, 
      role: 'admin',
      email: 'admin@logitrack.com',
      phone: '0000000000',
      age: '99',
      location: 'Headquarters'
    ));
    debugPrint("Database Initialized: Default Admin Created");
  }

  runApp(ParcelTrackerApp(sessionBox: sessionBox));
}

class ParcelTrackerApp extends StatelessWidget {
  final Box sessionBox;
  
  const ParcelTrackerApp({super.key, required this.sessionBox});

  @override
  Widget build(BuildContext context) {
    // 6. Check for Active Session
    Widget initialScreen = const LoginPage();
    
    // If a user was logged in previously, skip Login Page
    if (sessionBox.containsKey('currentUser')) {
      final username = sessionBox.get('currentUser');
      final role = sessionBox.get('currentRole');
      
      if (role == 'admin') {
        initialScreen = const AdminHome();
      } else {
        initialScreen = CustomerHome(username: username);
      }
    }

    return MaterialApp(
      title: 'LogiTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4), 
          primary: const Color(0xFF6750A4),
          secondary: const Color(0xFF03DAC6),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      home: initialScreen,
    );
  }
}