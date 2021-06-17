import 'package:allspice_mobile/models/spice.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:flutter/material.dart';

Color _mainColor = Color(0xFFE16723);

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
  List _freeContainers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  late List _takenContainers;

  @override
  void initState() {
    super.initState();

    checkContainers();

    favorite = widget.spice?.favorite ?? false;
    container = widget.spice?.container ?? _freeContainers[0];
    name = widget.spice?.name ?? '';
    nameController = TextEditingController(text: name);
  }

  void checkContainers() async {
    List _l = await SpiceDB.instance.readContainers();
    _freeContainers.removeWhere((element) => _l.contains(element));
    setState(() {
      container = _freeContainers[0];
    });
    print("Free containers:");
    print(_freeContainers);
  }

  List _getFreeContainers() {
    List _list = [];
    for (int i = 0; i < 10; i++) {
      _list.add(i);
    }
    return _list;
  }

  @override
  void dispose() {
    // Clean up the text controller
    nameController.dispose();
    super.dispose();
  }

  Future createSpice(String name, int container) async {
    Spice _s = Spice(name: name, container: container);
    await SpiceDB.instance.create(_s);
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
                    // initialValue: name,
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
                        labelText: "Container", labelStyle: TextStyle(fontSize: 35)),
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
                              color: Colors.black,
                            ),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith(
                                  (states) => Colors.grey)),
                        ),
                      ),

                      /// Submit Button
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Spice registered!"),
                                behavior: SnackBarBehavior.floating,
                                // shape: RoundedRectangleBorder(
                                //     borderRadius: BorderRadius.circular(20)),
                              ));

                              // TODO DEBUGGING
                              // String _s = nameController.text.trim();
                              print("Entered name: ${nameController.text.trim()};");
                              print("Selected container: $container;");

                              print("ADDING SPICE TO DB");
                              createSpice(nameController.text.trim(), container);

                              FocusScope.of(context).unfocus();
                              Navigator.of(context).pop(true);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => _mainColor),
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
}
