import 'package:allspice_mobile/bluetooth.dart';
import 'package:allspice_mobile/models/spice.dart';
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

    // Listen for further state changes
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        bluetoothState = state;

        getPairedDevices();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    spices = spices.isNotEmpty
        ? spices
        : ModalRoute.of(context)!.settings.arguments as List<Spice>;

    _screens = [
      RecipePage(),
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
