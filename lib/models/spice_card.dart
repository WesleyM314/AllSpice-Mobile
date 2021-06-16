import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allspice_mobile/models/spice.dart';

class SpiceCard extends StatefulWidget {
  final Spice spice;
  const SpiceCard({Key? key, required this.spice}) : super(key: key);

  @override
  _SpiceCardState createState() => _SpiceCardState();
}

class _SpiceCardState extends State<SpiceCard> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width * 0.75;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
      shadowColor: Color(0xDD000000),
      elevation: 3,
      // shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(10)),
      //     side: BorderSide(width: 3, color: Colors.blue)),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 170),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                  child: Text(
                    widget.spice.name,
                    textAlign: TextAlign.left,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(1, 30, 15, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        print("Delete ${widget.spice.name}");
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        print("Edit ${widget.spice.name}");
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.blue[900],
                        size: 35,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        print("Favorite ${widget.spice.name}");
                        setState(() {
                          widget.spice.favorite = !widget.spice.favorite;
                        });
                      },
                      icon: Icon(
                        widget.spice.favorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red[900],
                        size: 35,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        print("Dispense ${widget.spice.name}");
                      },
                      icon: Icon(
                        Icons.play_arrow_outlined,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
