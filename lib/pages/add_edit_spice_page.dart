import 'dart:convert';
import 'dart:typed_data';

import 'package:allspice_mobile/bluetooth.dart';
import 'package:allspice_mobile/constants.dart';
import 'package:allspice_mobile/models/spice.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:flutter/material.dart';

class AddEditSpicePage extends StatefulWidget {
  final Spice? spice;

  const AddEditSpicePage({Key? key, this.spice}) : super(key: key);

  @override
  _AddEditSpicePageState createState() => _AddEditSpicePageState();
}

class _AddEditSpicePageState extends State<AddEditSpicePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final nameController;
  late bool favorite;
  late int container;
  late String name;
  late bool isUpdate;

  List _freeContainers = List<int>.generate(MAX_NUM_SPICES, (index) => index);

  @override
  void initState() {
    super.initState();
    // Is this an update or a new spice?
    isUpdate = widget.spice != null;

    checkContainers();

    favorite = widget.spice?.favorite ?? false;
    container = widget.spice?.container ?? _freeContainers[0];
    name = widget.spice?.name ?? '';
    nameController = TextEditingController(text: name);
  }

  void checkContainers() async {
    // Get free containers
    List _l = await SpiceDB.instance.readContainers();
    _freeContainers.removeWhere((element) => _l.contains(element));

    // If an update, allow selection of spice's container
    if (isUpdate) {
      _freeContainers.add(widget.spice?.container);
    }
    _freeContainers.sort();
    setState(() {
      if (!isUpdate) {
        container = _freeContainers[0];
      }
    });
  }

  @override
  void dispose() {
    // Clean up the text controller
    nameController.dispose();
    super.dispose();
  }

  Future createSpice(String name, int container) async {
    Spice _s = Spice(name: name, container: container);
    await SpiceDB.instance.createSpice(_s);
  }

  Future updateSpice(String name, int container) async {
    widget.spice?.name = name;
    widget.spice?.container = container;
    await SpiceDB.instance.updateSpice(widget.spice!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // backgroundColor: Colors.greenAccent,
        body: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: !isUpdate,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 24,
                    decoration: InputDecoration(
                      labelText: "Spice Name",
                      // hintText: "Hint",
                      labelStyle: TextStyle(fontSize: 26),
                      errorStyle: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    validator: (value) {
                      value?.trim();
                      if (value == null || value.isEmpty) {
                        return "Please add a name for the spice";
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField(
                    items: _freeContainers.map((num) {
                      return DropdownMenuItem(
                        value: num,
                        child: Text('$num'),
                      );
                    }).toList(),
                    value: container,
                    style: TextStyle(fontSize: 25, color: Colors.black),
                    onChanged: (newVal) {
                      setState(() {
                        container = newVal as int;
                      });
                    },
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: "Container",
                      labelStyle: TextStyle(fontSize: 35),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: _refill,
                          child: Text(
                            "Refill",
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => Colors.grey)),
                        ),
                      ),

                      /// Submit Button
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              List<int> sendBuffer = [];
                              // Update
                              if (isUpdate) {
                                // If container changed, tell device to delete
                                // spice at previous container
                                if (container != widget.spice!.container) {
                                  sendBuffer.addAll(
                                      [DELETE, widget.spice!.container]);
                                  sendBuffer.addAll(ascii.encode("\n"));
                                  await sendData(sendBuffer);
                                  // TODO wait for device response
                                  await Future.delayed(
                                      Duration(milliseconds: 500));
                                }
                                // Send command to register spice; if container is
                                // the same, device just changes the name
                                sendBuffer.clear();
                                sendBuffer.addAll([REGISTER, container]);
                                sendBuffer.addAll(ascii
                                    .encode(nameController.text.trim() + "\n"));
                                await sendData(sendBuffer);
                                await Future.delayed(
                                    Duration(milliseconds: 500));
                                // TODO wait for response from device
                                updateSpice(
                                    nameController.text.trim(), container);
                              } else {
                                // Send Bluetooth command to register spice
                                sendBuffer.addAll([REGISTER, container]);
                                sendBuffer.addAll(ascii
                                    .encode(nameController.text.trim() + "\n"));
                                await sendData(sendBuffer);
                                // TODO wait for response from device
                                createSpice(
                                    nameController.text.trim(), container);
                              }

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Spice registered!"),
                                behavior: SnackBarBehavior.floating,
                              ));

                              FocusScope.of(context).unfocus();
                              Navigator.of(context).pop(true);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => mainColor),
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _refill() async {
    if (connected) {
      List<int> sendBuffer = [REFILL, widget.spice!.container];
      sendBuffer.addAll(ascii.encode("\n"));
      await sendData(sendBuffer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Refill command sent!",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Remove from lowSpices
      if (lowSpices.contains(widget.spice!.container)) {
        lowSpices.remove(widget.spice!.container);
        widget.spice!.low = false;
        SpiceDB.instance.updateSpice(widget.spice!);
      }
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Bluetooth not connected to AllSpice device; cannot refill.",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
