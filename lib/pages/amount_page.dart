import 'dart:convert';
import 'dart:typed_data';

import 'package:allspice_mobile/bluetooth.dart';
import 'package:allspice_mobile/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:allspice_mobile/models/spice.dart';
import 'package:flutter/services.dart';

class AmountPage extends StatefulWidget {
  final Spice? spice;
  final bool dispense;

  const AmountPage({Key? key, this.spice, this.dispense = true}) : super(key: key);

  @override
  _AmountPageState createState() => _AmountPageState();
}

class _AmountPageState extends State<AmountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final numController = TextEditingController(text: "0");
  int unit = 0;
  int fraction = -1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("AllSpice"),
          elevation: 1,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 30),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/circles.png"),
              alignment: Alignment.bottomRight,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 50,
                        // maxHeight: 60,
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.5,
                            ),
                          ),
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        style: TextStyle(fontSize: 30),
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        controller: numController,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (str) {
                          // print(str.substring(str.length - 1));
                          numController.text = str.substring(str.length - 1);
                          numController.selection = TextSelection.fromPosition(
                              TextPosition(offset: numController.text.length));
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                    buildUnitToggle(),
                  ],
                ),
                SizedBox(height: 15),
                Icon(
                  Icons.add,
                  size: 30,
                ),
                SizedBox(height: 15),
                buildFractionSelect(),
                SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 25),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey),
                          padding: MaterialStateProperty.resolveWith((states) =>
                              EdgeInsets.symmetric(vertical: 10, horizontal: 10))),
                    ),
                    SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: () async {
                        // Unit: 0 = tsp, 1 = tbsp
                        int _count = 0;
                        if (unit == 0) {
                          _count = int.parse(numController.text) * 4;
                          _count += (fraction + 1); // Add 1/4, 1/2, or 3/4
                        } else if (unit == 1) {
                          // 3 tsp in 1 tbsp; each dispense is 1/4 tsp
                          _count = int.parse(numController.text) * 3 * 4;
                          // 1/4 tbsp = 3/4 tsp = 3 units
                          // 1/2 tbsp = 1.5 tsp = 6 units
                          // 3/4 tbsp = 2.25 tsp = 9 units
                          _count += (fraction + 1) * 3;
                        }

                        Navigator.of(context)
                            .pop(widget.dispense ? _count : [unit, _count]);
                      },
                      child: Text(
                        widget.dispense ? "Dispense" : "Confirm",
                        // "Dispense",
                        style: TextStyle(fontSize: 25),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.green),
                          padding: MaterialStateProperty.resolveWith((states) =>
                              EdgeInsets.symmetric(vertical: 10, horizontal: 10))),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildUnitToggle() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(width: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                unit = 0;
              });
            },
            child: Text(
              "Tsp",
              style: TextStyle(fontSize: 25),
            ),
            style: ButtonStyle(
                backgroundColor: unit == 0
                    ? MaterialStateProperty.resolveWith((states) => mainColor)
                    : MaterialStateProperty.resolveWith((states) => Colors.grey),
                padding: MaterialStateProperty.resolveWith(
                    (states) => EdgeInsets.symmetric(vertical: 7, horizontal: 5))),
          ),
          SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                unit = 1;
              });
            },
            child: Text(
              "Tbsp",
              style: TextStyle(fontSize: 25),
            ),
            style: ButtonStyle(
                backgroundColor: unit == 1
                    ? MaterialStateProperty.resolveWith((states) => mainColor)
                    : MaterialStateProperty.resolveWith((states) => Colors.grey),
                padding: MaterialStateProperty.resolveWith(
                    (states) => EdgeInsets.symmetric(vertical: 7, horizontal: 5))),
          ),
        ],
      ),
    );
  }

  Widget buildFractionSelect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              fraction = fraction == 0 ? -1 : 0;
            });
          },
          child: Text(
            "1/4",
            style: TextStyle(fontSize: 25),
          ),
          style: ButtonStyle(
              backgroundColor: fraction == 0
                  ? MaterialStateProperty.resolveWith((states) => mainColor)
                  : MaterialStateProperty.resolveWith((states) => Colors.grey),
              padding: MaterialStateProperty.resolveWith(
                  (states) => EdgeInsets.symmetric(vertical: 7, horizontal: 5))),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              fraction = fraction == 1 ? -1 : 1;
            });
          },
          child: Text(
            "1/2",
            style: TextStyle(fontSize: 25),
          ),
          style: ButtonStyle(
              backgroundColor: fraction == 1
                  ? MaterialStateProperty.resolveWith((states) => mainColor)
                  : MaterialStateProperty.resolveWith((states) => Colors.grey),
              padding: MaterialStateProperty.resolveWith(
                  (states) => EdgeInsets.symmetric(vertical: 7, horizontal: 5))),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              fraction = fraction == 2 ? -1 : 2;
            });
          },
          child: Text(
            "3/4",
            style: TextStyle(fontSize: 25),
          ),
          style: ButtonStyle(
              backgroundColor: fraction == 2
                  ? MaterialStateProperty.resolveWith((states) => mainColor)
                  : MaterialStateProperty.resolveWith((states) => Colors.grey),
              padding: MaterialStateProperty.resolveWith(
                  (states) => EdgeInsets.symmetric(vertical: 7, horizontal: 5))),
        ),
      ],
    );
  }
}
