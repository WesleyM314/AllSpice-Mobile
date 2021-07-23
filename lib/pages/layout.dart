import 'dart:convert';
import 'dart:typed_data';

import 'package:allspice_mobile/bluetooth.dart';
import 'package:allspice_mobile/models/recipe.dart';
import 'package:allspice_mobile/models/screen_args.dart';
import 'package:allspice_mobile/models/spice.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:allspice_mobile/pages/recipe_page.dart';
import 'package:allspice_mobile/pages/settings_page.dart';
import 'package:allspice_mobile/pages/spice_page.dart';
import 'package:flutter/material.dart';
import 'package:allspice_mobile/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MyLayout extends StatefulWidget {
  MyLayout({Key? key}) : super(key: key);

  // final String title;

  @override
  _MyLayoutState createState() => _MyLayoutState();
}

class _MyLayoutState extends State<MyLayout> {
  int _currentIndex = 1;

  // late int deviceState;
  // List<BluetoothDevice> devicesList = [];
  // bool isDisconnecting = false;

  List<Spice> spices = [];
  List<Recipe> recipes = [];

  PageController _pageController = PageController(initialPage: 1);
  List<Widget> _screens = [];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Get current BT state
    FlutterBluetoothSerial.instance.state.then((value) {
      setState(() {
        bluetoothState = value;
      });
    });

    deviceState = 0; // neutral

    // If BT not enabled, request permission to turn
    // it on
    enableBluetooth();

    // Try to connect to AllSpice device
    connect();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        bluetoothState = state;
        print("BLUETOOTH STATE CHANGE");
        getPairedDevices();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenArgs args = ModalRoute.of(context)!.settings.arguments as ScreenArgs;

    spices = spices.isNotEmpty ? spices : args.spices;
    recipes = recipes.isNotEmpty ? recipes : args.recipes;

    _screens = [
      RecipePage(recipes: recipes),
      SpicePage(spices: spices),
      SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("AllSpice"),
        elevation: 1,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/circles.png"),
            alignment: Alignment.bottomRight,
          ),
        ),
        child: PageView(
          controller: _pageController,
          children: _screens,
          onPageChanged: _onPageChanged,
          // physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        elevation: 0,
        iconSize: 35.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: mainColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_book,
            ),
            label: "",
            tooltip: "Recipes",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "",
            tooltip: "Spices",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: "",
            tooltip: "Settings",
          )
        ],
        onTap: (index) {
          // _pageController.jumpToPage(index);
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
        },
      ),
    );
  }

  Future<void> enableBluetooth() async {
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If BT is off, turn it on first and retrieve
    // paired devices
    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return;
    } else {
      await getPairedDevices();
    }
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

  void connect() async {
    // TODO if connection fails, schedule job to attempt periodically
    // Get paired devices
    await getPairedDevices();

    // Attempt connection
    devicesList.forEach((element) async {
      if (element.name == "AllSpice") {
        print("Attempting to connect to AllSpice");
        if (!isConnected) {
          // Try connecting using address
          await BluetoothConnection.toAddress(element.address)
              .then((_connection) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Connected to AllSpice!"),
              behavior: SnackBarBehavior.floating,
            ));

            print("Connected");
            connection = _connection;

            setState(() {
              connected = true;
            });

            // Tracks when disconnecting process is in progress using
            // [isDisconnecting] variable
            //TODO handle incoming messages
            connection!.input.listen((Uint8List data) {
              inputBuffer.addAll(data);
              if (ascii.decode(inputBuffer).contains("\n")) {
                print("Data Incoming: ${ascii.decode(inputBuffer)}");
                if (inputBuffer[0] == LOW_SPICE) {
                  lowSpices
                      .addAll(inputBuffer.getRange(1, inputBuffer.length - 1));
                }
                if (ascii.decode(inputBuffer).compareTo("DONE\r\n") == 0) {
                  print("DONE");
                  processDone = true;
                }
                inputBuffer.clear();
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
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    super.dispose();
  }
}
