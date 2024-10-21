import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gigacharge/utils/tile_providers.dart';
import 'package:latlong2/latlong.dart';

class MarkerMap extends StatefulWidget {
  static const String route = '/markers';

  const MarkerMap({super.key});

  @override
  State<MarkerMap> createState() => _MarkerMapState();
}

class _MarkerMapState extends State<MarkerMap> {
  Alignment selectedAlignment = Alignment.topCenter;
  bool counterRotate = false;

  static const alignments = {
    315: Alignment.topLeft,
    0: Alignment.topCenter,
    45: Alignment.topRight,
    270: Alignment.centerLeft,
    null: Alignment.center,
    90: Alignment.centerRight,
    225: Alignment.bottomLeft,
    180: Alignment.bottomCenter,
    135: Alignment.bottomRight,
  };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(21.2998, -157.8148),
                initialZoom: 5,
                onTap: (_, p) => setState(() => customMarkers.add(buildPin(p))),
                interactionOptions: const InteractionOptions(
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
                  markers: customMarkers,
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