import 'package:allspice_mobile/models/spice_db.dart';
import 'package:allspice_mobile/pages/add_edit_spice_page.dart';
import 'package:allspice_mobile/pages/amount_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allspice_mobile/models/spice.dart';

class SpiceCard extends StatefulWidget {
  final Spice spice;
  final Function refreshFunction;

  const SpiceCard(
      {Key? key, required this.spice, required this.refreshFunction})
      : super(key: key);

  @override
  _SpiceCardState createState() => _SpiceCardState();
}

class _SpiceCardState extends State<SpiceCard> {
  @override
  Widget build(BuildContext context) {
    // double _width = MediaQuery.of(context).size.width * 0.75;
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
                    // DELETE BUTTON
                    IconButton(
                      onPressed: () async {
                        // print("Delete ${widget.spice.name}");
                        // Show confirmation dialog
                        await _deleteDialog();

                        widget.refreshFunction();
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                    // EDIT BUTTON
                    IconButton(
                      onPressed: () async {
                        print("Edit ${widget.spice.name}");
                        dynamic result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddEditSpicePage(spice: widget.spice)));
                        if(result != null) {
                          widget.refreshFunction();
                        }
                      },
                      icon: Icon(
                        Icons.edit_outlined,
                        color: Colors.blue[900],
                        size: 35,
                      ),
                    ),
                    // FAVORITE BUTTON
                    IconButton(
                      onPressed: () async {
                        print("Favorite ${widget.spice.name}");
                        setState(() {
                          widget.spice.favorite = !widget.spice.favorite;
                        });
                        await SpiceDB.instance.update(widget.spice);
                        // widget.refreshFunction();
                      },
                      icon: Icon(
                        widget.spice.favorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red[900],
                        size: 35,
                      ),
                    ),
                    // DISPENSE BUTTON
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

  /// Build and show confirmation dialog to delete spice

  Future<void> _deleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: SingleChildScrollView(
              child: Column(
            children: [
              Text("Are you sure you want to delete ${widget.spice.name}?"),
            ],
          )),
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
                print("Delete ${widget.spice.name}");
                await SpiceDB.instance.delete(widget.spice.id!);
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
