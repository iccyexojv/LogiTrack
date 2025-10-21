// filename: pages/customer_home.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../model/parcel.dart';

class CustomerHome extends StatefulWidget {
  final String username;
  const CustomerHome({super.key, required this.username});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  List<Parcel> parcels = [];

  @override
  void initState() {
    super.initState();

    // Example parcels (replace with Hive fetch if needed)
    parcels = [
      Parcel(
          trackingNumber: 'PK001',
          sender: 'Kathmandu',
          recipient: 'Butwal',
          status: 'In Transit',
          history: []),
      Parcel(
          trackingNumber: 'PK002',
          sender: 'Pokhara',
          recipient: 'Biratnagar',
          status: 'Delivered',
          history: []),
    ];
  }

  void _logout() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: parcels.length,
        itemBuilder: (context, index) {
          final parcel = parcels[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Parcel ${parcel.trackingNumber}'),
              subtitle: Text('Status: ${parcel.status}\nFrom: ${parcel.sender} To: ${parcel.recipient}'),
            ),
          );
        },
      ),
    );
  }
}
