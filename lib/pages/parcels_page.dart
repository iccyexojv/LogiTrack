import 'package:flutter/material.dart';
import '../model/parcel.dart';
import 'parcel_details_page.dart';

class ParcelsPage extends StatelessWidget {
  final List<Parcel> parcels;

  const ParcelsPage({super.key, required this.parcels});

  @override
  Widget build(BuildContext context) {
    if (parcels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.deepPurple.shade100),
            const SizedBox(height: 16),
            Text(
              "No Active Shipments",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: parcels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final parcel = parcels[index];
        return _buildParcelCard(context, parcel);
      },
    );
  }

  Widget _buildParcelCard(BuildContext context, Parcel parcel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ParcelDetailsPage(parcel: parcel)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: Tracking ID & Status ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_shipping, size: 20, color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("TRACKING ID", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1.2)),
                            Text(
                              parcel.trackingNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildStatusChip(parcel.status),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),

                // --- ROUTE: From -> To ---
                Row(
                  children: [
                    // From
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("FROM", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            parcel.fromLocation ?? "N/A",
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(parcel.sender, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    
                    // Arrow Icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_right_alt, color: Colors.deepPurple.shade200, size: 30),
                    ),

                    // To
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("TO", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            parcel.toLocation ?? "N/A",
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(parcel.recipient, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- FOOTER: Location Hint ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, size: 14, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          parcel.history.isNotEmpty 
                            ? "Last Update: ${parcel.history.last.location}" 
                            : "Ready for pickup",
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color text;
    IconData icon;

    switch (status) {
      case 'Delivered':
        bg = Colors.green.shade50;
        text = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'In Transit':
        bg = Colors.blue.shade50;
        text = Colors.blue.shade700;
        icon = Icons.local_shipping;
        break;
      case 'Cancelled':
        bg = Colors.red.shade50;
        text = Colors.red.shade700;
        icon = Icons.cancel;
        break;
      default: // Pending / Created
        bg = Colors.orange.shade50;
        text = Colors.orange.shade800;
        icon = Icons.inventory_2;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}