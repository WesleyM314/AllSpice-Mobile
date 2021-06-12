import 'package:flutter/material.dart';
import 'package:allspice_mobile/pages/layout.dart';
import 'package:flutter/services.dart';

Color mainColor = Color(0xFFE16723);

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIOverlays([
  //   SystemUiOverlay.bottom,
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // primarySwatch: Colors.deepOrange,
        primaryColor: mainColor,
        // accentColor: mainColor,
      ),
      home: MyLayout(),
    );
  }
}
