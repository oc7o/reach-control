import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mqtt_provider.dart';

class TestGpsWidget extends StatelessWidget {
  const TestGpsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttProvider>();
    final gps = mqtt.gpsPosition;

    return Column(
      children: [
        ElevatedButton(
          onPressed:
              mqtt.isConnected ? () => mqtt.sendCommand('get_gps') : null,
          child: const Text('GPS anfordern'),
        ),
        const SizedBox(height: 10),
        gps != null
            ? Text(
                '📍 GPS:\nLat: ${gps['lat']}\nLon: ${gps['lon']}\nAlt: ${gps['alt']} m',
              )
            : const Text('Noch keine GPS-Daten'),
      ],
    );
  }
}
