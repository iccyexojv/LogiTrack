class Graph {
  final Map<String, Map<String, int>> edges = {};

  void addEdge(String from, String to, int distance) {
    edges.putIfAbsent(from, () => {});
    edges[from]![to] = distance;

    edges.putIfAbsent(to, () => {});
    edges[to]![from] = distance; // undirected graph
  }

  List<String> shortestPath(String start, String end) {
    final distances = <String, int>{};
    final previous = <String, String?>{};
    final unvisited = <String>{};

    for (var node in edges.keys) {
      distances[node] = 1 << 30; // Infinity
      previous[node] = null;
      unvisited.add(node);
    }

    distances[start] = 0;

    while (unvisited.isNotEmpty) {
      var current = unvisited.reduce(
          (a, b) => distances[a]! < distances[b]! ? a : b);

      if (distances[current] == (1 << 30)) break; // no reachable nodes left
      if (current == end) break;
      unvisited.remove(current);

      edges[current]?.forEach((neighbor, distance) {
        if (!unvisited.contains(neighbor)) return;
        var alt = distances[current]! + distance;
        if (alt < distances[neighbor]!) {
          distances[neighbor] = alt;
          previous[neighbor] = current;
        }
      });
    }

    // Build path safely
    var path = <String>[];
    String? current = end; // make nullable

    if (previous[end] != null || start == end) {
      while (current != null) {
        path.insert(0, current);
        current = previous[current]; // now safe
      }
    }

    return path;
  }
}
