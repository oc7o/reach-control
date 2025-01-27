import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  SettingsFormState createState() {
    return SettingsFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SettingsFormState extends State<SettingsForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final settingsBrokerController = TextEditingController();
  final settingsBrokerPortController = TextEditingController();
  final settingsBrokerTopicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTextFromPreferences();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    settingsBrokerController.dispose();
    settingsBrokerPortController.dispose();
    settingsBrokerTopicController.dispose();
    super.dispose();
  }

  Future<void> _loadTextFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final brokerText = prefs.getString('BROKER') ?? '';
    final brokerPortText = prefs.getString('BROKER_PORT') ?? '';
    final brokerTopicText = prefs.getString('BROKER_TOPIC') ?? '';
    setState(() {
      settingsBrokerController.text =
          brokerText; // Wert dem TextEditingController zuweisen
      settingsBrokerPortController.text = brokerPortText;
      settingsBrokerTopicController.text = brokerTopicText;
    });
  }

  Future<void> _saveTextToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('BROKER', settingsBrokerController.text);
    await prefs.setString('BROKER_PORT', settingsBrokerPortController.text);
    await prefs.setString('BROKER_TOPIC', settingsBrokerTopicController.text);
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'BROKER',
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    controller: settingsBrokerController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'BROKER Address/Domain';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'BROKER Port',
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    controller: settingsBrokerPortController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'BROKER Port';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: Text(
                                'BROKER Topic',
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    controller: settingsBrokerTopicController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'BROKER Topic';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: _saveTextToPreferences,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            )));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: const SettingsForm(),
    );
  }
}
