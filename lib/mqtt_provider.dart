import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class MqttProvider extends ChangeNotifier {
  // mqtt client
  late MqttServerClient _client;

  // client connection state
  MqttConnectionState _connectionState = MqttConnectionState.disconnected;

  MqttConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == MqttConnectionState.connected;

  // topic
  String? _topic;

  // messages
  final List<String> _messages = []; // Liste für eingehende Nachrichten
  List<String> get messages => _messages; // Getter für Komponenten

  // GPS
  Map<String, dynamic>? _lastGps;
  Map<String, dynamic>? get gpsPosition => _lastGps;

  Future<void> connectAndSubscribe(String brokerIP, String topic) async {
    if (_connectionState == MqttConnectionState.connecting ||
        _connectionState == MqttConnectionState.connected) {
      debugPrint('⏳ Already connected or connecting');
      return;
    }

    _setConnectionState(MqttConnectionState.connecting);
    _topic = topic;

    _client = MqttServerClient(brokerIP, 'flutter_client');
    _client.port = 1883;
    _client.logging(on: false);
    _client.keepAlivePeriod = 2;
    _client.autoReconnect = true;

    // Callbacks
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnected = _onAutoReconnected;

    // _client.onSubscribed = (String topic) {
    //   debugPrint('📋 Subscribed: $topic');
    // };

    try {
      await _client.connect();
      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> events) {
        final MqttPublishMessage message =
            events[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        _messages.add(payload); // Nachricht speichern
        notifyListeners(); // App-Komponenten informieren
      });
    } catch (e) {
      debugPrint('⚠️ Connection error: $e');
      _client.disconnect();
    }
  }

  void _onConnected() {
    debugPrint('✅ Connected to mqtt broker');
    _subscribeToTopic();
    _setConnectionState(MqttConnectionState.connected);
  }

  void _onDisconnected() {
    _setConnectionState(MqttConnectionState.disconnected);
    debugPrint('❌ Connection to mqtt broker lost');
  }

  void _onAutoReconnect() {
    debugPrint('🔄 Trying auto reconnect to mqtt broker');
    _setConnectionState(MqttConnectionState.reconnecting);
  }

  void _onAutoReconnected() {
    debugPrint('✅ Auto reconnected to mqtt broker');
    _subscribeToTopic();
    _setConnectionState(MqttConnectionState.connected);
  }

  void _setConnectionState(MqttConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      notifyListeners();
    }
  }

  void _subscribeToTopic() {
    if (_topic != null) {
      _client.subscribe(_topic!, MqttQos.atLeastOnce);
      debugPrint('📡 Subscribed: $_topic');
    }

    // subscribe resonse topic
    _client.subscribe('reach/response', MqttQos.atLeastOnce);

    // Listener
    _client.updates!.listen(_handleIncomingMessage);
  }

  void _handleIncomingMessage(List<MqttReceivedMessage<MqttMessage>> c) {
    final recMess = c[0].payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    debugPrint('📥 Received response: $payload');

    try {
      final data = json.decode(payload);

      switch (data['type']) {
        case 'get_gps':
          _lastGps = {
            'lat': data['lat'],
            'lon': data['lon'],
            'alt': data['alt'],
          };
          notifyListeners();
          break;

        case 'ping':
          debugPrint('💡 Drone is online');
          break;

        default:
          debugPrint('⚠️ Unknown response type: ${data['type']}');
      }
    } catch (e) {
      debugPrint('❌ Parsing error: $e');
    }
  }

  void sendCommand(String type, [Map<String, dynamic>? payload]) {
    if (!isConnected) return;

    final msg = {
      'type': type,
      ...?payload,
    };

    final builder = MqttClientPayloadBuilder();
    builder.addString(json.encode(msg));

    _client.publishMessage(
      'reach/command',
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    debugPrint('➡️  sent: $msg');
  }

  /// **Funktion zum Veröffentlichen von Nachrichten**
  /// THIS FUNCTION WILL BE REMOVED / REPLACED BY sendCommand
  void publishMessage(String topic, String message) {
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      debugPrint("Sent message: $message to topic: $topic");
    } else {
      debugPrint("MQTT is not connected. Cannot send message.");
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners(); // Notify components to refresh
  }

  void disconnect() {
    _client.disconnect();
    _setConnectionState(MqttConnectionState.disconnected);
  }

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }
}
