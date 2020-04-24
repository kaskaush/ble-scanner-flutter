import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location/location.dart';
import 'package:sensors/sensors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Scanner',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'BLE Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

extension Precision on num {
  num toPrecision(int fractionDigits) {
    num mod = pow(10, fractionDigits.toDouble());
    return ((this * mod).round().toDouble() / mod);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<ScanResult> results = [];

  BluetoothDevice device;
  BluetoothState state;
  BluetoothDeviceState deviceState;
  Future<bool> locationServiceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;

  void _showDialog(String message) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Bluetooth"),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  num Function(num) distance = (data) {
    return pow(10, ((-69 - (data)) / 100)).toPrecision(3);
  };

  void scanDevices(flutterBlue) async {
    List<ScanResult> resultsList = [];

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        var isUnique = true;
        for (var i = 0; i < resultsList.length; i++) {
          if (resultsList[i].device.id == r.device.id) {
            isUnique = false;
          }
        }
        if (isUnique) {
          resultsList.add(r);
        }
      }
    });
    setState(() {
      results = resultsList;
    });
  }

  void initState() {
    super.initState();
    Location location = new Location();
    locationServiceEnabled = location.serviceEnabled();
    FlutterBlue flutterBlue = FlutterBlue.instance;
    var scanSubscription;

    if (locationServiceEnabled == null) {
      _showDialog('Please switch on your GPS');
    }

    num lastX = 0;
    num lastY = 0;

    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        _showDialog('Please switch on your bluetooth.');
      } else if (state == BluetoothState.on) {
        scanDevices(flutterBlue);
      }
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      num diffX = event.x - lastX;
      num diffY = event.y - lastY;

      if (diffX > 1 || diffY > 1) {
        // device moved
        flutterBlue.stopScan();
        scanSubscription.cancel();
        flutterBlue.startScan(timeout: Duration(seconds: 4));
      }

      lastX = event.x;
      lastY = event.y;
    });

    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Device list:',
            ),
            Container(
              height: 600.0, // Change as per your requirement
              width: 500.0, // Change as per your requirement
              child: new ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Text(
                      '${results[index].device.name}.. rssi: ${results[index]
                          .rssi} distance: ${distance(results[index].rssi)}');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
