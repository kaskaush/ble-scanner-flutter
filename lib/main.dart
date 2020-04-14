import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:location/location.dart';

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

  Widget getBLEList(results) {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: new ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          return new Text(
              '${results[index].device.id}.. rssi: ${results[index].rssi}');
        },
      ),
    );
  }

  void _showListDialog(results) {
    // flutter defined function
    if (results.length > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("BLE device list"),
            content: getBLEList(results),
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
  }

  void initState() {
    super.initState();
    Location location = new Location();
    locationServiceEnabled = location.serviceEnabled();

    if (locationServiceEnabled == null) {
      _showDialog('Please switch on your GPS');
    }

    List<ScanResult> resultsList = [];
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        _showDialog('Please switch on your bluetooth.');
      } else if (state == BluetoothState.on) {
        flutterBlue.scanResults.listen((results) {
          for (ScanResult r in results) {
            resultsList.add(r);
          }
        });
        setState(() {
          results = resultsList;
        });

        //_showListDialog(resultsList);
      }
    });

    flutterBlue.stopScan();
  }

  void scanForDevices() async {}

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
              height: 300.0, // Change as per your requirement
              width: 300.0, // Change as per your requirement
              child: new ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (BuildContext context, int index) {
                  return new Text(
                      '${results[index].device.id}.. rssi: ${results[index].rssi}');
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
