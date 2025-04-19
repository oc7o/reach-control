import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../mqtt_provider.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MqttProvider>().connectionState;

    Color color;
    String text;

    switch (state) {
      case MqttConnectionState.connected:
        color = Colors.green;
        text = "Connected to mqtt";
        break;
      case MqttConnectionState.connecting:
        color = Colors.orange;
        text = "Connecting…";
        break;
      case MqttConnectionState.reconnecting:
        color = Colors.orangeAccent;
        text = "Reconnecting…";
        break;
      case MqttConnectionState.disconnected:
      default:
        color = Colors.red;
        text = "Disconnected";
    }

    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 14),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}
