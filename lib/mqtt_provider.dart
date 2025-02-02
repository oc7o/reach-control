import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttProvider extends ChangeNotifier {
  late MqttServerClient client;
  final List<String> _messages = []; // Liste für eingehende Nachrichten

  List<String> get messages => _messages; // Getter für Komponenten

  Future<void> connectAndSubscribe(String brokerIP, String topic) async {
    print('ASDF: $brokerIP');
    client = MqttServerClient(brokerIP, 'flutter_client');
    client.port = 1883;
    client.logging(on: false);

    client.onConnected = () {
      print('Verbunden mit Broker!');
      client.subscribe(topic, MqttQos.atLeastOnce);
    };

    client.onDisconnected = () {
      print('Verbindung verloren');
    };

    client.onSubscribed = (String topic) {
      print('Abonniert: $topic');
    };

    try {
      await client.connect();
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> events) {
        final MqttPublishMessage message =
            events[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        _messages.add(payload); // Nachricht speichern
        notifyListeners(); // App-Komponenten informieren
      });
    } catch (e) {
      print('Verbindungsfehler: $e');
      client.disconnect();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners(); // Notify components to refresh
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }
}
