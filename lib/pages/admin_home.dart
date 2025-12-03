import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/parcel.dart';
import 'add_edit_parcel_page.dart';
import 'admin_create_user_page.dart';
import 'login_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // Access the Parcel Database
  final Box<Parcel> box = Hive.box<Parcel>('parcels');
  String _searchQuery = "";

  // Logout Logic: Clears session and redirects to Login
  void _logout() {
    final sessionBox = Hive.box('session');
    sessionBox.clear(); // Wipe the auto-login data

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false, // Remove all previous screens from the stack
    );
  }

  // Helper: Get background color for status chip
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.green.shade100;
      case 'In Transit': return Colors.blue.shade100;
      case 'Cancelled': return Colors.red.shade100;
      default: return Colors.orange.shade100;
    }
  }

  // Helper: Get text color for status chip
  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.green.shade800;
      case 'In Transit': return Colors.blue.shade800;
      case 'Cancelled': return Colors.red.shade800;
      default: return Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      // --- DRAWER (SIDEBAR) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Admin"),
              accountEmail: Text("Administrator Access"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: Color(0xFF6750A4), size: 30),
              ),
              decoration: BoxDecoration(color: Color(0xFF6750A4)),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Manage Parcels'),
              onTap: () => Navigator.pop(context), // Already here, just close drawer
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Create New Customer'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCreateUserPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      // --- MAIN CONTENT ---
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Token, Sender or Receiver...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          
          // 2. Parcel List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Parcel> box, _) {
                // Get list and apply search filter
                var parcels = box.values.toList();
                
                if (_searchQuery.isNotEmpty) {
                  parcels = parcels.where((p) => 
                    p.trackingNumber.toLowerCase().contains(_searchQuery) ||
                    p.sender.toLowerCase().contains(_searchQuery) ||
                    p.recipient.toLowerCase().contains(_searchQuery)
                  ).toList();
                }

                if (parcels.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text("No shipments found", style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: parcels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final parcel = parcels[index];
                    
                    // Dismissible allows swiping to delete
                    return Dismissible(
                      key: Key(parcel.trackingNumber),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog(
                          context: context, 
                          builder: (ctx) => AlertDialog(
                            title: const Text("Delete Parcel?"),
                            content: Text("Are you sure you want to delete ${parcel.trackingNumber}?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false), 
                                child: const Text("Cancel")
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true), 
                                child: const Text("Delete", style: TextStyle(color: Colors.red))
                              ),
                            ],
                          )
                        );
                      },
                      onDismissed: (_) => parcel.delete(),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => AddEditParcelPage(isEdit: true, parcel: parcel))
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: const Icon(Icons.local_shipping, color: Colors.deepPurple),
                          ),
                          title: Text(parcel.trackingNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("${parcel.sender} ➔ ${parcel.recipient}"),
                              const SizedBox(height: 2),
                              Text(
                                parcel.history.isNotEmpty ? "📍 ${parcel.history.last.location}" : "📍 Created",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _getStatusColor(parcel.status), 
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Text(
                              parcel.status, 
                              style: TextStyle(
                                color: _getStatusTextColor(parcel.status), 
                                fontWeight: FontWeight.bold, 
                                fontSize: 10
                              )
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("New Shipment"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditParcelPage(isEdit: false))),
      ),
    );
  }
}