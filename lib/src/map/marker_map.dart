import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gigacharge/utils/tile_providers.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MarkerMap extends StatefulWidget {
  static const String route = '/markers';

  const MarkerMap({super.key});

  @override
  State<MarkerMap> createState() => _MarkerMapState();
}

class _MarkerMapState extends State<MarkerMap> {
  LatLng? currentLocation;
  late StreamSubscription<Position> positionStream;
  final Map<LatLng, int> markerQueueCounts = {
    LatLng(21.296940, -157.817108): 3,
    LatLng(21.3001, -157.8194): 5,
    LatLng(21.2982, -157.8123): 7,
  };

  @override
  void initState() {
    super.initState();
    if (mounted) {
      getCurrentLocation();
    }
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    try {
      if (mounted) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return;
        }
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });

        positionStream = Geolocator.getPositionStream().listen((Position position) {
          setState(() {
            currentLocation = LatLng(position.latitude, position.longitude);
          });
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Color getMarkerColor(int count) {
    if (count <= 5) {
      return count == 5 ? Colors.yellow : Colors.green;
    } else {
      return Colors.red;
    }
  }

  void navigateToQueueScreen(LatLng markerLocation, int queueCount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QueueScreen(markerLocation: markerLocation, queueCount: queueCount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(21.2998, -157.8148),
          initialZoom: 14,
        ),
        children: [
          openStreetMapTileLayer,
          MarkerLayer(
            markers: markerQueueCounts.entries.map((entry) {
              final location = entry.key;
              final count = entry.value;
              return Marker(
                point: location,
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => navigateToQueueScreen(location, count),
                  child: Icon(Icons.location_pin, size: 60, color: getMarkerColor(count)),
                ),
              );
            }).toList()
              ..addAll(
                currentLocation != null
                    ? [
                  Marker(
                    point: currentLocation!,
                    width: 60,
                    height: 60,
                    child: const Icon(Icons.my_location, size: 30, color: Colors.blue),
                  )
                ]
                    : [],
              ),
          ),
        ],
      ),
    );
  }
}

class QueueScreen extends StatelessWidget {
  final LatLng markerLocation;
  final int queueCount;

  const QueueScreen({
    super.key,
    required this.markerLocation,
    required this.queueCount,
  });

  @override
  Widget build(BuildContext context) {
    List<String> queue = List.generate(queueCount, (index) => "Person ${index + 1}");
    int userPosition = queueCount ~/ 2; // Mocked user position in the queue

    return Scaffold(
      appBar: AppBar(title: const Text("Queue Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Queue at ${markerLocation.latitude}, ${markerLocation.longitude}", style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Text("Number of people in queue: $queueCount"),
            const SizedBox(height: 16),
            Text("Your position in the queue: ${userPosition + 1}"),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(child: Text("${index + 1}"), backgroundColor: Colors.lightBlueAccent,),
                    title: Text(queue[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
