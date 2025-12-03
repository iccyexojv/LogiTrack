import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/user.dart';
import '../model/parcel.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final List<Parcel> parcels;

  const ProfilePage({
    super.key,
    required this.username,
    required this.parcels,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Fetch User Data from Database
    final userBox = Hive.box<User>('users');
    
    // Safely find user, fallback if not found (shouldn't happen)
    final user = userBox.values.firstWhere(
      (u) => u.username == username,
      orElse: () => User(username: username, passwordHash: '', role: 'customer'), 
    );

    // 2. Calculate Real-time Statistics
    final total = parcels.length;
    final pending = parcels.where((p) => p.status == 'Pending' || p.status == 'Created').length;
    final inTransit = parcels.where((p) => p.status == 'In Transit').length;
    final outDelivery = parcels.where((p) => p.status == 'Out for Delivery').length;
    final delivered = parcels.where((p) => p.status == 'Delivered').length;
    final cancelled = parcels.where((p) => p.status == 'Cancelled').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // --- HEADER SECTION ---
          _buildUserHeader(user),
          const SizedBox(height: 20),

          // --- CONTACT DETAILS ---
          if (user.email.isNotEmpty || user.phone.isNotEmpty)
            _buildContactCard(user),

          const SizedBox(height: 25),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Shipment Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),

          // --- STATISTICS GRID ---
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard("Total Orders", total.toString(), Icons.inventory_2, Colors.deepPurple),
              _buildStatCard("Delivered", delivered.toString(), Icons.check_circle, Colors.green),
              _buildStatCard("Out for Delivery", outDelivery.toString(), Icons.delivery_dining, Colors.orange.shade700),
              _buildStatCard("In Transit", inTransit.toString(), Icons.local_shipping, Colors.blue),
              _buildStatCard("Pending", pending.toString(), Icons.hourglass_top, Colors.amber.shade700),
              _buildStatCard("Cancelled", cancelled.toString(), Icons.cancel, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.deepPurple),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username, 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      user.location.isNotEmpty ? user.location : "Location N/A",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContactCard(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        children: [
          if (user.email.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 18, color: Colors.deepPurple),
                  const SizedBox(width: 10),
                  Text(user.email, style: TextStyle(color: Colors.deepPurple.shade800)),
                ],
              ),
            ),
          if (user.phone.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 18, color: Colors.deepPurple),
                const SizedBox(width: 10),
                Text(user.phone, style: TextStyle(color: Colors.deepPurple.shade800)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}