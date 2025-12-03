import 'package:flutter/material.dart';
import '../model/parcel.dart';
import 'package:intl/intl.dart';

class ParcelDetailsPage extends StatelessWidget {
  final Parcel parcel;

  const ParcelDetailsPage({super.key, required this.parcel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking Details")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Visual Map / Route Header
            Container(
              width: double.infinity,
              height: 180,
              color: Colors.deepPurple.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 60, color: Colors.deepPurple),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(parcel.fromLocation ?? 'Origin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_right_alt, color: Colors.grey),
                      ),
                      Text(parcel.toLocation ?? 'Dest', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Text("Status: ${parcel.status}", style: TextStyle(color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold))
                ],
              ),
            ),

            // 2. Timeline List
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Shipment History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  if (parcel.history.isEmpty) 
                    const Text("No history available.")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: parcel.history.length,
                      itemBuilder: (ctx, i) {
                        // Reverse so newest is top
                        final event = parcel.history.reversed.toList()[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time
                            SizedBox(
                              width: 50,
                              child: Text(
                                DateFormat('MMM dd').format(event.timestamp), 
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)
                              ),
                            ),
                            // Line
                            Column(
                              children: [
                                Container(
                                  width: 12, height: 12,
                                  decoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                                ),
                                Container(width: 2, height: 60, color: Colors.grey.shade300),
                              ],
                            ),
                            const SizedBox(width: 15),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.location, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(event.description, style: TextStyle(color: Colors.grey.shade600)),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}