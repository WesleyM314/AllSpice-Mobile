import 'package:allspice_mobile/main.dart';
import 'package:allspice_mobile/models/spice.dart';
import 'package:allspice_mobile/models/spice_card.dart';
import 'package:flutter/material.dart';

class SpicePage extends StatefulWidget {
  final List<Spice> spices;
  const SpicePage({Key? key, required this.spices}) : super(key: key);

  @override
  _SpicePageState createState() => _SpicePageState();
}

class _SpicePageState extends State<SpicePage> with AutomaticKeepAliveClientMixin {
  // Dummy Spices
  // Spice s1 = Spice(name: "Cinnamon", container: 1);
  // Spice s2 = Spice(name: "Cloves", container: 2, favorite: true);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: widget.spices.isEmpty
          ? Center(
              child: Text(
              "No Spices",
              style: TextStyle(
                fontSize: 30,
              ),
            ))
          : ListView.builder(
              itemCount: widget.spices.length,
              itemBuilder: (context, index) {
                return SpiceCard(spice: widget.spices[index]);
              },
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
