import 'package:allspice_mobile/pages/loading.dart';
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
  // runApp(MyApp());
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: mainColor,
      accentColor: mainColor,
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => Loading(),
      '/home': (context) => MyLayout(),
    },
  ));
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // title: 'AllSpice',
//       theme: ThemeData(
//         primaryColor: mainColor,
//       ),
//       initialRoute: '/home',
//       routes: {
//         '/home': (context) => MyLayout(),
//         // '/amount': (context) => AmountSelect(),
//       },
//       // home: MyLayout(),
//     );
//   }
// }
