import 'package:flutter/material.dart';
import 'package:reach_control/components/reach_navigation_bar.dart';
import 'package:reach_control/components/connected_indicator.dart';
import 'package:reach_control/components/test_gps_widget.dart';
import '../mqtt_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var brokerText = '';
  var brokerPortText = '';
  var brokerTopicText = '';

  late VlcPlayerController _vlcController;
  bool _isControllerInitialized = false;
  bool holdPosition = false;

  @override
  void initState() {
    super.initState();
    _vlcController = VlcPlayerController.network(
      'http://127.0.0.1:8080/?action=stream',
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    // Wait for initialization before using the controller
    _vlcController.initialize().then((_) {
      setState(() {
        _isControllerInitialized = true;
      });
    });
  }

  Future<void> _loadTextFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    brokerText = prefs.getString('BROKER') ?? '';
    brokerPortText = prefs.getString('BROKER_PORT') ?? '';
    brokerTopicText = prefs.getString('BROKER_TOPIC') ?? '';
  }

  Future<void> _takeUp() async {
    await _loadTextFromPreferences();
    if (!mounted) return;

    final mqttProvider = Provider.of<MqttProvider>(context, listen: false);
    mqttProvider.publishMessage(brokerTopicText, 'takeUp');
  }

  Future<void> _land() async {
    await _loadTextFromPreferences();
    if (!mounted) return;

    final mqttProvider = Provider.of<MqttProvider>(context, listen: false);
    mqttProvider.publishMessage(brokerTopicText, 'land');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: [
              const Text('Hello, World!'),
              ElevatedButton(
                onPressed: _takeUp,
                child: const Text('⬆️ Take Up! ⬆️'),
              ),
              ElevatedButton(
                onPressed: _land,
                child: const Text('⬇️ Land! ⬇️'),
              ),
              Checkbox(
                checkColor: Colors.white,
                value: holdPosition,
                onChanged: (bool? value) {
                  setState(() {
                    holdPosition = value!;
                  });
                },
              ),
              Center(
                child: _isControllerInitialized
                    ? VlcPlayer(
                        controller: _vlcController,
                        aspectRatio: 16 / 9,
                        placeholder: Center(child: Text("ASDF")),
                      )
                    : const Center(
                        child:
                            CircularProgressIndicator()), // Show loading until initialized
              ), // TODO: make BROKER_IP
              const ConnectionIndicator(),
              const TestGpsWidget()
            ],
          ),
        ),
        bottomNavigationBar: const ReachNavigationBar());

    // return Scaffold(
    //    appBar: AppBar(
    //      // Here we take the value from the HomePage object that was created by
    //      // the App.appState property, and use it to set our appbar title.
    //      title: const Text("Reach-Control"),
    //      ),
    //    bottomNavigationBar: NavigationBar(

    // return FlutterMap(
    //   mapController: MapController(),
    //   options: const MapOptions(
    //       initialCenter: LatLng(37.812596, -122.477937), initialZoom: 15),
    //   children: [
    //     TileLayer(
    //         urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
    //     const MarkerLayer(
    //       markers: [
    //         Marker(
    //           point: LatLng(30, 40),
    //           width: 80,
    //           height: 80,
    //           child: FlutterLogo(),
    //         ),
    //       ],
    //     ),
    //   ],
    // );
    // return Scaffold(
    //   appBar: AppBar(
    //     // TRY THIS: Try changing the color here to a specific color (to
    //     // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
    //     // change color while the other colors stay the same.
    //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //     // Here we take the value from the HomePage object that was created by
    //     // the App.build method, and use it to set our appbar title.
    //     title: Text(widget.title),
    //   ),
    //   body: Center(
    //     // Center is a layout widget. It takes a single child and positions it
    //     // in the middle of the parent.
    //     child: Column(
    //       // Column is also a layout widget. It takes a list of children and
    //       // arranges them vertically. By default, it sizes itself to fit its
    //       // children horizontally, and tries to be as tall as its parent.
    //       //
    //       // Column has various properties to control how it sizes itself and
    //       // how it positions its children. Here we use mainAxisAlignment to
    //       // center the children vertically; the main axis here is the vertical
    //       // axis because Columns are vertical (the cross axis would be
    //       // horizontal).
    //       //
    //       // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
    //       // action in the IDE, or press "p" in the console), to see the
    //       // wireframe for each widget.
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         const Text(
    //           'You have pushed the button this many times:',
    //         ),
    //         Text(
    //           '$_counter',
    //           style: Theme.of(context).textTheme.headlineMedium,
    //         ),
    //       ],
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Increment',
    //     child: const Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );
  }
}
