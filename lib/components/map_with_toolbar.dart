import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import '../mqtt_provider.dart';

class MapWithToolbar extends StatefulWidget {
  const MapWithToolbar({super.key});

  @override
  State<MapWithToolbar> createState() => _MapWithToolbarState();
}

class _MapWithToolbarState extends State<MapWithToolbar> {
  late final MapController _mapController;

  Timer? _gpsTimer;

  var brokerText = '';
  var brokerPortText = '';
  var brokerTopicText = '';

  Future<void> _loadTextFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    brokerText = prefs.getString('BROKER') ?? '';
    brokerPortText = prefs.getString('BROKER_PORT') ?? '';
    brokerTopicText = prefs.getString('BROKER_TOPIC') ?? '';
  }

  Future<void> _initializeConnection() async {
    await _loadTextFromPreferences();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MqttProvider>(context, listen: false)
          .connectAndSubscribe(brokerText, brokerTopicText); // IP und Topic
    });
  }

  Future<void> _fetchGPSData() async {
    final mqttProvider = Provider.of<MqttProvider>(context, listen: false);
    if (mqttProvider.isConnected) {
      mqttProvider.sendCommand('get_gps');
      debugPrint("ℹ️ sent get_gps command");
    }
  }

  Future<void> _startFetchingGPS() async {
    _gpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchGPSData();
    });
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _initializeConnection();
    _startFetchingGPS();
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    final mqttProvider = Provider.of<MqttProvider>(context, listen: false);

    List<Marker> markers = new List.empty(growable: true);
    if (mqttProvider.gpsPosition != null) {
      markers.add(Marker(
          point: LatLng(mqttProvider.gpsPosition!['lat'],
              mqttProvider.gpsPosition!['lon']),
          width: 80,
          height: 80,
          child: const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.flight,
              color: Colors.green,
              size: 50.0,
            ),
          )));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Map'),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              // options: MapOptions(
              //     initialCenter: LatLng(52.520008, 13.404954), initialZoom: 18),
              options: MapOptions(
                initialCenter: mqttProvider.gpsPosition != null
                    ? LatLng(mqttProvider.gpsPosition!['lat'],
                        mqttProvider.gpsPosition!['lon'])
                    : const LatLng(52.520008, 13.404954),
                initialZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all, // Maus, Scroll, Drag, etc.
                ),
              ),
              children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                MarkerLayer(
                  markers: markers,
                ),
              ],
            ), // bottomNavigationBar: const ReachNavigationBar()
            Positioned(
              top: 20,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoomIn',
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoomOut',
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    _gpsTimer?.cancel();
    super.dispose();
  }
}
