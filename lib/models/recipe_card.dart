import 'dart:convert';

import 'package:allspice_mobile/bluetooth.dart';
import 'package:allspice_mobile/constants.dart';
import 'package:allspice_mobile/models/recipe.dart';
import 'package:allspice_mobile/models/spice.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:allspice_mobile/pages/add_edit_recipe_page.dart';
import 'package:flutter/material.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final Function refreshFunction;

  const RecipeCard({Key? key, required this.recipe, required this.refreshFunction})
      : super(key: key);

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
      shadowColor: Color(0xDD000000),
      elevation: 3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 170),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                  child: Text(
                    widget.recipe.name,
                    textAlign: TextAlign.left,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
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
                        print("Edit ${widget.recipe.name}");
                        dynamic result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddEditRecipePage(recipe: widget.recipe)));
                        if (result != null) {
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
                        print("Favorite ${widget.recipe.name}");
                        setState(() {
                          widget.recipe.favorite = !widget.recipe.favorite;
                        });
                        await SpiceDB.instance.updateRecipe(widget.recipe);
                        // widget.refreshFunction();
                      },
                      icon: Icon(
                        widget.recipe.favorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red[900],
                        size: 35,
                      ),
                    ),
                    // DISPENSE BUTTON
                    IconButton(
                      onPressed: _dispense,
                      icon: Icon(
                        Icons.play_arrow_outlined,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // TODO send dispense command
  Future<void> _dispense() async {
    // Get list of currently registered spices
    List<Spice> s = await SpiceDB.instance.readAllSpices();
    List<String> registered = s.map((e) => e.name).toList();
    List<int> sendBuffer = [DISPENSE_SERIES, widget.recipe.ingredients!.length];
    widget.recipe.ingredients?.forEach((element) {
      if (!registered.contains(element.name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "This recipe uses a spice that is not registered. Cannot be dispensed."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      // Get container for spice
      sendBuffer
          .add(s.firstWhere((e) => e.name.compareTo(element.name) == 0).container);
      // Add amount
      sendBuffer.add(element.amount);
    });
    sendBuffer.addAll(ascii.encode("\n"));
    await sendData(sendBuffer);
    print("Dispense ${widget.recipe.name}");
    print("sendBuffer: $sendBuffer");
  }

  Future<void> _deleteDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("Are you sure you want to delete ${widget.recipe.name}?"),
              ],
            ),
          ),
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
                print("Delete ${widget.recipe.name}");
                await SpiceDB.instance.deleteRecipe(widget.recipe.id!);
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
            ),
          ],
        );
      },
    );
  }
}
