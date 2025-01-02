import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:reach_control/components/reach_navigation_bar.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Map'),
        ),
        body: FlutterMap(
          mapController: MapController(),
          options: const MapOptions(
              initialCenter: LatLng(52.520008, 13.404954), initialZoom: 18),
          children: [
            TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
            const MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(30, 40),
                  width: 80,
                  height: 80,
                  child: FlutterLogo(),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: const ReachNavigationBar());
  }
}
