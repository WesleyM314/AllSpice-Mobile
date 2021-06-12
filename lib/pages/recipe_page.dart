import 'package:flutter/material.dart';

import '../main.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({Key? key}) : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          "Recipe Page",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        child: FittedBox(
          child: FloatingActionButton(
            child: Icon(
              Icons.add,
              size: 35,
            ),
            backgroundColor: mainColor,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
