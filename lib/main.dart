import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  late BluetoothDevice _device;
  final String printerName = "XP-365B";
  final String macAddress = "DC:0D:30:18:42:6B";
  bool _connected = false;

  late String pathImage;

  @override
  void initState() {
    _device = BluetoothDevice(printerName, macAddress);
    _connected = _device.connected;
    if (kDebugMode) {
      print(_connected);
    }
    Map<dynamic, dynamic> deviceMap = _device.toMap();
    print(deviceMap);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Test")),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Device:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(_device.name!),
                ElevatedButton(
                  onPressed: _connected ? _disconnect : _connect,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          _connected ? Colors.green : Colors.red)),
                  child: Text(_connected ? 'On - Disconnect' : 'Off - Connect',
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
            child: ElevatedButton(
              onPressed: _connected ? _testPrint : null,
              child: const Text('TesPrint'),
            ),
          ),
        ],
      ),
    );
  }

  void _connect() {
    bluetooth.isConnected.then((isConnected) {
      if (!isConnected!) {
        bluetooth
            .connect(_device)
            .then((value) => setState(() => _connected = true));
      } else {
        setState(() => _connected = true);
      }
    });
  }

  void _disconnect() {
    bluetooth.disconnect().then(
          (value) => setState(() => _connected = false),
        );
  }

  void _testPrint() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

    if (kDebugMode) {
      print("Is it Connected? $_connected");
    }
    if (_connected) {
      bluetooth.printNewLine();
      bluetooth.printCustom("HEADER", 3, 1);
      bluetooth.printNewLine();
      //bluetooth.printImage(pathImage); //path of your image/logo
      bluetooth.printNewLine();
      //bluetooth.printImageBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      bluetooth.printLeftRight("LEFT", "RIGHT", 0);
      bluetooth.printLeftRight("LEFT", "RIGHT", 1);
      bluetooth.printLeftRight("LEFT", "RIGHT", 1, format: "%-15s %15s %n");
      bluetooth.printNewLine();
      bluetooth.printLeftRight("LEFT", "RIGHT", 2);
      bluetooth.printLeftRight("LEFT", "RIGHT", 3);
      bluetooth.printLeftRight("LEFT", "RIGHT", 4);
      bluetooth.printNewLine();
      bluetooth.print3Column("Col1", "Col2", "Col3", 1);
      bluetooth.print3Column("Col1", "Col2", "Col3", 1,
          format: "%-10s %10s %10s %n");
      bluetooth.printNewLine();
      bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 1);
      bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 1,
          format: "%-8s %7s %7s %7s %n");
      bluetooth.printNewLine();
      String testString = " čĆžŽšŠ-H-ščđ";
      bluetooth.printCustom(testString, 1, 1, charset: "windows-1250");
      bluetooth.printLeftRight("Številka:", "18000001", 1,
          charset: "windows-1250");
      bluetooth.printCustom("Body left", 1, 0);
      bluetooth.printCustom("Body right", 0, 2);
      bluetooth.printNewLine();
      bluetooth.printCustom("Thank You", 2, 1);
      bluetooth.printNewLine();
      bluetooth.printQRcode("Insert Your Own Text to Generate", 200, 200, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();
    } else {
      if (kDebugMode) {
        print("Printer Not Connected!!!");
      }
    }
  }

  show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
