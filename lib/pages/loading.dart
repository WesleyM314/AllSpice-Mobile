import 'package:allspice_mobile/models/ingredient.dart';
import 'package:allspice_mobile/models/recipe.dart';
import 'package:allspice_mobile/models/screen_args.dart';
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
  late List<Recipe> recipes;

  void loadSpices() async {
    List<Recipe> foo = await SpiceDB.instance.readAllRecipes();
    print("RECIPES");
    foo.forEach((e) {
      print(e.toJson());
      // print(e.ingredients);
      e.ingredients?.forEach((element) {
        print("\t\t${element.toJson()}");
      });
    });

    this.spices = await SpiceDB.instance.readAllSpices();
    this.recipes = await SpiceDB.instance.readAllRecipes();
    ScreenArgs args = ScreenArgs(spices, recipes);
    Navigator.pushReplacementNamed(context, '/home', arguments: args);
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
