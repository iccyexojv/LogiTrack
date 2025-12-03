import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart';
import '../model/parcel.dart';
import 'parcels_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class CustomerHome extends StatefulWidget {
  final String username;
  const CustomerHome({super.key, required this.username});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _selectedIndex = 0;
  late final Box<Parcel> parcelBox;

  @override
  void initState() {
    super.initState();
    parcelBox = Hive.box<Parcel>('parcels');
  }

  // LOGOUT: Clears the persistent session
  void _logout() {
    final sessionBox = Hive.box('session');
    sessionBox.clear(); 

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter logic: Only show parcels relevant to THIS customer
    // This variable is used for passing data to ProfilePage
    final myParcels = parcelBox.values.where((p) => 
      p.sender == widget.username || p.recipient == widget.username
    ).toList();

    Widget body;
    switch (_selectedIndex) {
      case 0:
        // 2. Reactive List: Updates automatically when Admin adds a parcel
        body = ValueListenableBuilder(
          valueListenable: parcelBox.listenable(),
          builder: (context, Box<Parcel> box, _) {
            final updatedParcels = box.values.where((p) => 
              p.sender == widget.username || p.recipient == widget.username
            ).toList();
            
            // Re-uses the beautiful layout we built in parcels_page.dart
            return ParcelsPage(parcels: updatedParcels);
          },
        );
        break;
      case 1:
        body = ProfilePage(username: widget.username, parcels: myParcels);
        break;
      case 2:
        body = SettingsPage(username: widget.username);
        break;
      default:
        body = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Custom Title with Welcome Message
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back,", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            Text(widget.username, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: "Logout",
              onPressed: _logout,
            ),
          )
        ],
      ),
      body: body,
      // Styled Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 20, offset: const Offset(0, -5))
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF6750A4),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Parcels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}