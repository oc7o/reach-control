import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import '../mqtt_provider.dart';

class DynamicMapWidget extends StatefulWidget {
  @override
  _DynamicMapWidgetState createState() => _DynamicMapWidgetState();
}

class _DynamicMapWidgetState extends State<DynamicMapWidget> {
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

  @override
  void initState() {
    super.initState();

    _initializeConnection();
  }

  @override
  Widget build(BuildContext context) {
    final mqttProvider = Provider.of<MqttProvider>(context);

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
                  point: LatLng(52.520008, 13.404954),
                  width: 80,
                  height: 80,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 50.0,
                    ),
                  )),
            ],
          ),
        ],
      ), // bottomNavigationBar: const ReachNavigationBar()
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicMapWidget();
  }
}
