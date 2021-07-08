import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// Init BT connection state to be unknown
BluetoothState bluetoothState = BluetoothState.UNKNOWN;
// Get instance of BT
FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
// Track BT connection with remote device
BluetoothConnection? connection;
// Track whether device is still connected
bool get isConnected => connection != null && connection!.isConnected;
// Variables used to manage Bluetooth
bool connected = false;
late int deviceState;
List<BluetoothDevice> devicesList = [];
bool isDisconnecting = false;
List<int> inputBuffer = [];
