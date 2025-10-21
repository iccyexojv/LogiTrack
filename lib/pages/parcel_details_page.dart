import 'package:flutter/material.dart';
import '../model/parcel.dart';

class ParcelDetailsPage extends StatelessWidget {
  final String trackingNumber;

  const ParcelDetailsPage({super.key, required this.trackingNumber});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final parcel = Parcel(
      trackingNumber: trackingNumber,
      sender: 'Alice',
      recipient: 'Bob',
      status: 'In Transit',
      history: [
        TrackingEvent(
            location: 'Kathmandu',
            description: 'Picked up',
            timestamp: DateTime.now().subtract(const Duration(days: 2))),
        TrackingEvent(
            location: 'Pokhara',
            description: 'In Transit',
            timestamp: DateTime.now().subtract(const Duration(days: 1))),
        TrackingEvent(
            location: 'Butwal',
            description: 'Out for Delivery',
            timestamp: DateTime.now()),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('Parcel: $trackingNumber')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParcelInfo(parcel),
            const SizedBox(height: 20),
            const Text(
              'Tracking History:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...parcel.history.reversed.map((event) => _buildHistoryTile(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelInfo(Parcel parcel) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sender: ${parcel.sender}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text('Recipient: ${parcel.recipient}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text('Status: ${parcel.status}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(TrackingEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.local_shipping, color: Colors.deepPurple),
        title: Text(event.description),
        subtitle: Text('${event.location} - ${_formatDate(event.timestamp)}'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
