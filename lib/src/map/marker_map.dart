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
  Alignment selectedAlignment = Alignment.topCenter;
  bool counterRotate = false;
  LatLng? currentLocation;
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    if (mounted) {
      getCurrentLocation();
    }
    super.initState();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    try {
      if (mounted) {
        // Request location permission
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return;
          }
        }
        // Get current position
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });

        // Set up location updates
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

  late final customMarkers = <Marker>[
    buildPin(const LatLng(21.296940, -157.817108)),
    buildPin(const LatLng(53.33360293799854, -6.284001062079881)),
  ];

  Marker buildPin(LatLng point) => Marker(
        point: point,
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tapped existing marker'),
              duration: Duration(seconds: 1),
              showCloseIcon: true,
            ),
          ),
          child: const Icon(Icons.location_pin, size: 60, color: Colors.black),
        ),
      );

  Marker buildCurrentLocationMarker(LatLng point) => Marker(
        point: point,
        width: 60,
        height: 60,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.my_location,
            size: 30,
            color: Colors.blue,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(21.2998, -157.8148),
                initialZoom: 10,
                interactionOptions: InteractionOptions(
                  flags: ~InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                openStreetMapTileLayer,
                MarkerLayer(
                  rotate: counterRotate,
                  markers: const [
                    Marker(
                      point: LatLng(0.296940, -157.817108),
                      width: 64,
                      height: 64,
                      alignment: Alignment.centerLeft,
                      child: ColoredBox(
                        color: Colors.lightBlue,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('-->'),
                        ),
                      ),
                    ),
                    Marker(
                      point: LatLng(47.18664724067855, -1.5436768515939427),
                      width: 64,
                      height: 64,
                      alignment: Alignment.centerRight,
                      child: ColoredBox(
                        color: Colors.pink,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('<--'),
                        ),
                      ),
                    ),
                    Marker(
                      point: LatLng(47.18664724067855, -1.5436768515939427),
                      rotate: false,
                      child: ColoredBox(color: Colors.black),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    ...customMarkers,
                    if (currentLocation != null)
                      buildCurrentLocationMarker(currentLocation!),
                  ],
                  rotate: counterRotate,
                  alignment: selectedAlignment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
