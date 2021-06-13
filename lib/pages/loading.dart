import 'package:allspice_mobile/models/spice.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  late List<Spice> spices;

  void loadSpices() async {
    this.spices = await SpiceDB.instance.readAll();
    // TODO remove dummy spice
    this.spices.add(Spice(name: "Oregano", container: 8, favorite: false));
    this.spices.add(Spice(name: "Cinnamon", container: 3));
    this.spices.add(Spice(name: "Cloves", container: 5));
    this.spices.add(Spice(name: "Allspice", container: 0, favorite: true));
    // print(this.spices);
    Navigator.pushReplacementNamed(context, '/home', arguments: spices);
  }

  @override
  void initState() {
    super.initState();
    loadSpices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitDualRing(
              color: Colors.white,
              size: 50,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Loading",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
