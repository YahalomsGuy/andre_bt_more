import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool switchOn = false;

  bool _connected = false;

  late String pathImage;

  @override
  void initState() {
    initPlatformState();
    _connected = stillConnected();
    setState(() {});
    super.initState();
  }

  bool stillConnected() {
    bool? isOn = false;
    bluetooth.isConnected.then((value) {
      isOn = value;
      return isOn;
    });
    return false;
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      if (kDebugMode) {
        print("PlatformException!");
      }
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            if (kDebugMode) {
              print("bluetooth device state: connected");
            }
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            if (kDebugMode) {
              print("bluetooth device state: disconnected");
            }
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            if (kDebugMode) {
              print("bluetooth device state: disconnect requested");
            }
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            if (kDebugMode) {
              print("bluetooth device state: bluetooth turning off");
            }
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            if (kDebugMode) {
              print("bluetooth device state: bluetooth off");
            }
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            if (kDebugMode) {
              print("bluetooth device state: bluetooth on");
            }
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            if (kDebugMode) {
              print("bluetooth device state: bluetooth turning on");
            }
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            if (kDebugMode) {
              print("bluetooth device state: error");
            }
          });
          break;
        default:
          if (kDebugMode) {
            print(state);
          }
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected!) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: smartText("Bluetooth Printer Test"),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                smartText('Device: \n Mac Address:',
                    color: Colors.black, bold: true),
                DropdownButton(
                  items: _getDeviceItems(),
                  onChanged: (BluetoothDevice? value) =>
                      setState(() => _device = value),
                  value: _device,
                ),
                //Text(_device.name!),
                const SizedBox()
              ],
            ),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: ElevatedButton(
              onPressed: _connected ? _disconnect : _connect,
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      _connected ? Colors.green : Colors.red)),
              child: SizedBox(
                height: 90,
                child: smartText(
                    _connected
                        ? 'Printer Connected \nPress to disconnect \nexpect 1 beep....'
                        : 'Printer disconnected \nPress to connect \nexpect 2 Beeps....',
                    size: 24),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              smartText("print mode", color: Colors.black, size: 24),
              CupertinoSwitch(
                value: switchOn,
                onChanged: (val) {
                  setState(() => switchOn = val);
                },
              ),
              smartText(switchOn ? "Long print" : "Short print",
                  color: Colors.black, size: 24, bold: true)
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: _connected ? _testPrint : null,
              child: SizedBox(
                height: 50,
                child: smartText('Print Test', size: 30, bold: true),
              ),
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
            .connect(_device!)
            .then((value) => setState(() => _connected = true));
        show("Connected!");
      } else {
        setState(() => _connected = true);
        show("Was connected, UI updated");
      }
    });
  }

  void _disconnect() {
    bluetooth.disconnect().then(
          (value) => setState(() => _connected = false),
        );
    show("Disconnected, UI updated");
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

    if (_connected) {
      try {
        bluetooth.write("1 \r\n");
        bluetooth.write("\n");
        bluetooth.printNewLine();
        bluetooth.printCustom("HEADER", 3, 1);
        bluetooth.printNewLine();
        //bluetooth.printImage(pathImage); //path of your image/logo
        bluetooth.printNewLine();
        //bluetooth.printImageBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
        bluetooth.printLeftRight("LEFT", "RIGHT", 0);
        bluetooth.printLeftRight("LEFT", "RIGHT", 1);
        if (switchOn) {
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
          bluetooth.printQRcode(
              "Insert Your Own Text to Generate", 200, 200, 1);
          bluetooth.printNewLine();
          bluetooth.printNewLine();
          bluetooth.paperCut();
        }
        show(switchOn
            ? "Printed Long Format\n Finished successfully!"
            : "Printed Short Format\n Finished successfully!");
      } catch (e) {
        show("Error: ${e.toString()}");
      }
    } else {
      show("Printer Disconnected");
    }
  }

  show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (kDebugMode) {
      print(message);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        content: smartText(
          message,
          size: 20,
        ),
        duration: duration,
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: smartText('NONE'),
      ));
    } else {
      for (var device in _devices) {
        items.add(DropdownMenuItem(
          value: device,
          child: smartText("${device.name!} \n ${device.address}",
              color: Colors.black),
        ));
      }
    }
    return items;
  }

  Widget smartText(String text,
      {double size = 18,
      Color color = Colors.white,
      bool bold = false,
      TextAlign align = TextAlign.center}) {
    return Text(text,
        textAlign: align,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ));
  }
}
