import 'dart:convert';

import 'package:allspice_mobile/bluetooth.dart';
import 'package:allspice_mobile/constants.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  BluetoothDevice? device;
  bool _isButtonUnavailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Enable Bluetooth"),
                Switch(
                  value: bluetoothState.isEnabled,
                  onChanged: (bool value) async {
                    if (value) {
                      // Enable BT
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      // Disable BT
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }

                    // Update devices list
                    await getPairedDevices();
                    _isButtonUnavailable = false;

                    setState(() {});
                  },
                ),
              ],
            ),
            Row(
              children: [
                DropdownButton(
                  hint: Text("Select Device"),
                  items: _getDeviceItems(),
                  onChanged: (value) {
                    setState(() {
                      device = value as BluetoothDevice?;
                    });
                  },
                  value: devicesList.isNotEmpty ? device : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: !bluetoothState.isEnabled
                          ? null
                          : connected
                              ? _disconnect
                              : _connect,
                      child: Text(connected ? "Disconnect" : "Connect"),
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _deleteDialog(true);
                  },
                  child: Text("Delete All Spices"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.red),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _deleteDialog(false);
                  },
                  child: Text("Delete All Recipes"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.red),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // Get list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error getting paired devices");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      devicesList = devices;
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (devicesList.isEmpty) {
      items.add(DropdownMenuItem(child: Text("NONE")));
    } else {
      devicesList.forEach((element) {
        items.add(DropdownMenuItem(
          child: Text(element.name),
          value: element,
        ));
      });
    }
    return items;
  }

  void _connect() async {
    if (device == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No device selected"),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      print(device);
      // If device selected...
      if (!isConnected) {
        // Try connecting using address
        await BluetoothConnection.toAddress(device!.address)
            .then((_connection) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Device connected!"),
            behavior: SnackBarBehavior.floating,
          ));
          print("Connected to device");
          connection = _connection;

          // Update connectivity status to true
          setState(() {
            connected = true;
          });

          // Tracks when disconnecting process is in progress using the
          // [isDisconnecting] variable
          connection!.input.listen((data) {
            if (data.isNotEmpty) {
              print("DATA INCOMING: $data");
            }
          }).onDone(() {
            if (isDisconnecting) {
              print("Disconnecting locally");
            } else {
              print("Disconnecting remotely");
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print("Cannot connect, exception occurred");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Connection error"),
            behavior: SnackBarBehavior.floating,
          ));
          print(error);
        });
      }
    }
  }

  void _disconnect() async {
    // Closing BT connection
    await connection!.close();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Device disconnected"),
      behavior: SnackBarBehavior.floating,
    ));

    // Update connected variable
    if (!connection!.isConnected) {
      setState(() {
        connected = false;
      });
    }
  }

  void _sendOnMessage() async {
    connection!.output.add(ascii.encode("1" + "\r\n"));
    await connection!.output.allSent;
  }

  void _sendOffMessage() async {
    connection!.output.add(ascii.encode("0" + "\r\n"));
    await connection!.output.allSent;
  }

  /// Build and show confirmation dialog to delete spice
  Future<void> _deleteDialog(bool s) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                    "Are you sure you want to delete all ${s ? "spices" : "recipes"}?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              onPressed: () async {
                if (s) {
                  // Spices
                  List<int> sendBuffer = [DELETE_ALL];
                  sendBuffer.addAll(ascii.encode("\n"));
                  await sendData(sendBuffer);
                  await SpiceDB.instance.deleteAllSpices();
                } else {
                  // Recipes
                  await SpiceDB.instance.deleteAllRecipes();
                }
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.resolveWith((states) => Colors.red),
              ),
            ),
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  // color: Colors.black,
                  fontSize: 15,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
