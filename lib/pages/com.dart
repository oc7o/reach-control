import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import '../mqtt_provider.dart';

class MqttScreen extends StatefulWidget {
  @override
  _MqttScreenState createState() => _MqttScreenState();
}

class _MqttScreenState extends State<MqttScreen> {
  var brokerText = '';
  var brokerPortText = '';
  var brokerTopicText = '';

  final ScrollController _scrollController = ScrollController();

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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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

    // Scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mqttProvider.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return Scaffold(
        appBar: AppBar(
          title: Text('Com'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                mqttProvider.clearMessages();
              },
              tooltip: 'Clear Messages',
            ),
          ],
        ),
        body: mqttProvider.messages.isEmpty
            ? const Center(
                child: Text(
                  'No messages have been received yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: mqttProvider.messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(mqttProvider.messages[index]),
                  );
                },
              ) // bottomNavigationBar: const ReachNavigationBar()
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ComPage extends StatelessWidget {
  const ComPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MqttScreen();
  }
}
