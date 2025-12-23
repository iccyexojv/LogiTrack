import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../model/parcel.dart'; // Keep your existing model import

// ---------------------------------------------------------------------------
// 1. DATA MODELS & DIJKSTRA ALGORITHM IMPLEMENTATION
// ---------------------------------------------------------------------------

/// Represents a Logistics Hub in Nepal
class LogisticsHub {
  final String id;
  final String name;
  final LatLng location;
  final bool isMainCenter;

  LogisticsHub({
    required this.id,
    required this.name,
    required this.location,
    this.isMainCenter = false,
  });
}

/// A weighted edge connecting two hubs
class RouteEdge {
  final String targetHubId;
  final double distanceKm;

  RouteEdge(this.targetHubId, this.distanceKm);
}

class LogisticsGraph {
  // Define major hubs in Nepal
  static final List<LogisticsHub> hubs = [
    LogisticsHub(id: 'KTM', name: 'Kathmandu Central', location: LatLng(27.7172, 85.3240), isMainCenter: true),
    LogisticsHub(id: 'PKR', name: 'Pokhara Hub', location: LatLng(28.2096, 83.9856)),
    LogisticsHub(id: 'CTN', name: 'Chitwan/Narayanghat', location: LatLng(27.6915, 84.4420)),
    LogisticsHub(id: 'BUT', name: 'Butwal Hub', location: LatLng(27.6866, 83.4323)),
    LogisticsHub(id: 'BIR', name: 'Biratnagar Hub', location: LatLng(26.4525, 87.2718)),
    LogisticsHub(id: 'HET', name: 'Hetauda Hub', location: LatLng(27.4172, 85.0325)),
  ];

  // Define the road network (Graph connections)
  // In a real app, this would come from a database or routing API.
  static final Map<String, List<String>> _connections = {
    'KTM': ['HET', 'PKR', 'CTN'], // Kathmandu connects to Hetauda, Pokhara, Chitwan
    'HET': ['KTM', 'CTN', 'BIR'], // Hetauda connects to Ktm, Chitwan, Biratnagar
    'CTN': ['KTM', 'HET', 'PKR', 'BUT'], 
    'PKR': ['KTM', 'CTN', 'BUT'],
    'BUT': ['PKR', 'CTN'],
    'BIR': ['HET'],
  };

  /// Dijkstra's Algorithm to find shortest path
  static Map<String, dynamic> findShortestPath(String startId, String endId) {
    // 1. Setup Distance Calculator
    const Distance distanceCalc = Distance();
    
    // 2. Build Adjacency List with Real Weights (Distances)
    final Map<String, List<RouteEdge>> graph = {};
    
    for (var hub in hubs) {
      graph[hub.id] = [];
      List<String> neighbors = _connections[hub.id] ?? [];
      
      for (var neighborId in neighbors) {
        var neighbor = hubs.firstWhere((h) => h.id == neighborId);
        double dist = distanceCalc.as(LengthUnit.Kilometer, hub.location, neighbor.location);
        graph[hub.id]!.add(RouteEdge(neighborId, dist));
      }
    }

    // 3. Dijkstra Initialization
    Map<String, double> distances = {for (var h in hubs) h.id: double.infinity};
    Map<String, String?> previous = {for (var h in hubs) h.id: null};
    List<String> unvisited = hubs.map((h) => h.id).toList();

    distances[startId] = 0;

    // 4. Algorithm Loop
    while (unvisited.isNotEmpty) {
      // Get node with smallest distance
      unvisited.sort((a, b) => distances[a]!.compareTo(distances[b]!));
      String current = unvisited.first;
      unvisited.remove(current);

      if (current == endId) break; // Reached destination
      if (distances[current] == double.infinity) break; // No path

      for (var edge in graph[current]!) {
        double alt = distances[current]! + edge.distanceKm;
        if (alt < distances[edge.targetHubId]!) {
          distances[edge.targetHubId] = alt;
          previous[edge.targetHubId] = current;
        }
      }
    }

    // 5. Reconstruct Path
    List<LatLng> pathPoints = [];
    List<String> pathNames = [];
    String? step = endId;
    
    if (previous[step] != null || step == startId) {
      while (step != null) {
        var hub = hubs.firstWhere((h) => h.id == step);
        pathPoints.insert(0, hub.location);
        pathNames.insert(0, hub.name);
        step = previous[step];
      }
    }

    return {
      'distance': distances[endId],
      'points': pathPoints,
      'pathNames': pathNames,
    };
  }
}

// ---------------------------------------------------------------------------
// 2. THE UI WIDGET
// ---------------------------------------------------------------------------

class ParcelDetailsPage extends StatefulWidget {
  final Parcel parcel;

  const ParcelDetailsPage({super.key, required this.parcel});

  @override
  State<ParcelDetailsPage> createState() => _ParcelDetailsPageState();
}

class _ParcelDetailsPageState extends State<ParcelDetailsPage> {
  // Results from Dijkstra
  List<LatLng> routePoints = [];
  double totalDistance = 0.0;
  String routeDescription = "";
  
  // Example: Let's assume the Parcel is moving from Biratnagar -> Pokhara
  // In a real app, these IDs would come from your Parcel object.
  final String startHubId = 'BIR'; 
  final String endHubId = 'PKR';

  @override
  void initState() {
    super.initState();
    _calculateRoute();
  }

  void _calculateRoute() {
    final result = LogisticsGraph.findShortestPath(startHubId, endHubId);
    setState(() {
      routePoints = result['points'] as List<LatLng>;
      totalDistance = result['distance'] as double;
      List<String> names = result['pathNames'] as List<String>;
      routeDescription = names.join(" ➝ ");
    });
  }

  @override
  Widget build(BuildContext context) {
    // Center map roughly between start and end
    final centerPoint = LatLng(27.7172, 85.3240); // Default Ktm

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Logistics Map"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------------------------------------
            // 1. MAP SECTION
            // ---------------------------------------------
            SizedBox(
              height: 350,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: centerPoint,
                  initialZoom: 7.5, // Zoomed out to see Nepal
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.parcel_tracker',
                  ),
                  
                  // LAYER: Shortest Path Line
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blueAccent,
                       // isDotted: true, // Styling the path
                      ),
                    ],
                  ),

                  // LAYER: Markers for Hubs
                  MarkerLayer(
                    markers: LogisticsGraph.hubs.map((hub) {
                      bool isStart = hub.id == startHubId;
                      bool isEnd = hub.id == endHubId;
                      bool isPathNode = routePoints.contains(hub.location);

                      return Marker(
                        point: hub.location,
                        width: 50,
                        height: 50,
                        child: Column(
                          children: [
                            Icon(
                              hub.isMainCenter ? Icons.star : Icons.location_on,
                              color: isStart ? Colors.green : (isEnd ? Colors.red : (hub.isMainCenter ? Colors.amber : Colors.grey)),
                              size: hub.isMainCenter ? 35 : 25,
                            ),
                            if (hub.isMainCenter || isStart || isEnd)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                                child: Text(hub.id, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // ---------------------------------------------
            // 2. ROUTE INFO SECTION
            // ---------------------------------------------
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.deepPurple.shade50,
              child: Column(
                children: [
                  const Text("OPTIMIZED ROUTE (DIJKSTRA)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(height: 10),
                  Text(
                    routeDescription.isNotEmpty ? routeDescription : "Calculating...",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoBadge(Icons.straighten, "${totalDistance.toStringAsFixed(1)} km", "Distance"),
                      _infoBadge(Icons.timer, "${(totalDistance / 50).toStringAsFixed(1)} hrs", "Est. Time"), // Approx 50km/hr avg
                    ],
                  )
                ],
              ),
            ),

            // ---------------------------------------------
            // 3. ORIGINAL TIMELINE (Kept from your code)
            // ---------------------------------------------
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Shipment History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  // ... (Keep your existing ListView.builder code here)
                  // Just a placeholder text for brevity in this example:
                  if (widget.parcel.history.isEmpty) 
                    const Text("No history available.")
                  else
                    // Reusing your exact existing logic logic
                     ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.parcel.history.length,
                      itemBuilder: (ctx, i) {
                        final event = widget.parcel.history.reversed.toList()[i];
                        return ListTile(
                          leading: const Icon(Icons.circle, size: 10, color: Colors.deepPurple),
                          title: Text(event.description),
                          subtitle: Text(DateFormat('MMM dd, hh:mm a').format(event.timestamp)),
                        );
                      },
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}