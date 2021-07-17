import 'dart:ui';

import 'package:allspice_mobile/constants.dart';
import 'package:allspice_mobile/models/ingredient.dart';
import 'package:allspice_mobile/models/recipe.dart';
import 'package:allspice_mobile/models/spice.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:allspice_mobile/pages/amount_page.dart';
import 'package:flutter/material.dart';

// Callback typedef
typedef void DeleteCallback(Key key);

class AddEditRecipePage extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipePage({Key? key, this.recipe}) : super(key: key);

  @override
  _AddEditRecipePageState createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final nameController;
  late bool favorite;
  late String name;
  late List<Ingredient> ingredients;
  late bool isUpdate;

  late List<Spice> spices;
  List<IngredientSelector> _dropdowns = [];

  @override
  void initState() {
    super.initState();

    // getAvailableSpices();
    isUpdate = widget.recipe != null;

    favorite = widget.recipe?.favorite ?? false;
    name = widget.recipe?.name ?? '';
    ingredients = widget.recipe?.ingredients ?? [];
    nameController = TextEditingController(text: name);

    if (isUpdate) {
      ingredients.forEach((i) {
        _dropdowns.add(IngredientSelector(
          removeFunction: removeDropdown,
          key: UniqueKey(),
          name: i.name,
          amount: i.amount,
        ));
        IngredientSelector.usedSpices.add(i.name);
      });
    } else {
      IngredientSelector.updateUsed([]);
      _dropdowns.add(IngredientSelector(
        key: UniqueKey(),
        removeFunction: removeDropdown,
      ));
    }
  }

  Future<void> getAvailableSpices() async {
    // Get spices not selected in a dropdown
    List<Spice> _l = await SpiceDB.instance.readAllSpices();
    spices = await SpiceDB.instance.readAllSpices();
    spices.removeWhere((element) => _l.contains(element));
  }

  void removeDropdown(Key key) {
    // print("Removing something");
    // print(_dropdowns);
    _dropdowns.removeWhere((element) => element.key == key);
    // print(_dropdowns);
    if (_dropdowns.length == 0) {
      _dropdowns.add(IngredientSelector(
        key: UniqueKey(),
        name: '',
        removeFunction: removeDropdown,
      ));
      // print(_dropdowns);
    }
    setState(() {});
  }

  @override
  void dispose() {
    // Clean up the text controller
    nameController.dispose();
    super.dispose();
  }

  Future createRecipe(String name, List<Ingredient> ingredients) async {
    Recipe _r = Recipe(name: name, ingredients: ingredients);
    await SpiceDB.instance.createRecipe(_r);
  }

  Future updateRecipe(String name, List<Ingredient> ingredients) async {
    widget.recipe?.name = name;
    widget.recipe?.ingredients = ingredients;
    await SpiceDB.instance.updateRecipe(widget.recipe!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: false,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: "Recipe Name",
                      labelStyle: TextStyle(fontSize: 26),
                      errorStyle: TextStyle(fontSize: 16),
                    ),
                    validator: (value) {
                      value?.trim();
                      if (value == null || value.isEmpty) {
                        return "Please add a name for the recipe";
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(height: 0),
                  Container(
                    // constraints: BoxConstraints(maxHeight: 800),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: this._dropdowns.length,
                      itemBuilder: (context, index) {
                        return _dropdowns[index];
                      },
                      physics: const AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            child: Text(
                              "Add a Spice",
                              style: TextStyle(
                                color: _dropdowns.length > MAX_NUM_SPICES - 1
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            onPressed: _add,
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith(
                                    (states) =>
                                        _dropdowns.length > MAX_NUM_SPICES - 1
                                            ? Colors.grey
                                            : Colors.lightBlue)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // CANCEL BUTTON
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
                      // SUBMIT BUTTON
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: ElevatedButton(
                          child: Text(
                            "Submit",
                            style: TextStyle(fontSize: 25),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => mainColor),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              name = nameController.text.trim();
                              print("isUpdate = $isUpdate");
                              if (isUpdate) {
                                _dropdowns
                                    .removeWhere((element) => element.name!.isEmpty);
                                List<Ingredient> _i = _dropdowns
                                    .map((e) => Ingredient(
                                          name: e.name!,
                                          amount: e.amount!,
                                        ))
                                    .toList();
                                Recipe _r = widget.recipe!.copy(ingredients: _i);
                                await SpiceDB.instance.updateRecipe(_r);

                                FocusScope.of(context).unfocus();
                                Navigator.of(context).pop(true);
                              } else {
                                // Make ingredients
                                _dropdowns
                                    .removeWhere((element) => element.name!.isEmpty);
                                List<Ingredient> _i = _dropdowns
                                    .map((e) => Ingredient(
                                          name: e.name!,
                                          amount: e.amount!,
                                        ))
                                    .toList();
                                // Create recipe
                                Recipe _r = Recipe(name: name, ingredients: _i);
                                print("ADDING RECIPE");
                                print("_r: ${_r.toJson()}");
                                _r.ingredients?.forEach((element) {
                                  print("i: ${element.toJson()}");
                                });
                                _r = await SpiceDB.instance.createRecipe(_r);
                                print("RECIPE ADDED TO DB");
                                print("_r: ${_r.toJson()}");
                                _r.ingredients?.forEach((element) {
                                  print("i: ${element.toJson()}");
                                });

                                FocusScope.of(context).unfocus();
                                Navigator.of(context).pop(true);
                              }
                            }
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _add() async {
    // _dropdowns = List.from(_dropdowns)..add(value)
    // If there's already an empty ingredients dropdown, just move it to the bottom
    for (var x in _dropdowns) {
      // print(x.name);
      if (x.name?.compareTo('') == 0 || x.name == null) {
        _dropdowns.remove(x);
        _dropdowns.add(x);
        // print(_dropdowns);
        return;
      }
    }
    // Add new spice selection dropdown
    _dropdowns.add(IngredientSelector(
      key: UniqueKey(),
      removeFunction: removeDropdown,
    ));
    setState(() {});
  }
}

class IngredientSelector extends StatefulWidget {
  String? name;
  int? amount;
  final DeleteCallback removeFunction;

  IngredientSelector(
      {Key? key, this.name, this.amount, required this.removeFunction})
      : super(key: key);

  @override
  _IngredientSelectorState createState() => _IngredientSelectorState();

  static List<String> usedSpices = [];
  static void updateUsed(List<String> u) {
    usedSpices = u;
  }
}

class _IngredientSelectorState extends State<IngredientSelector> {
  late String name;
  late int amount;
  List<String> spices = [];
  int unit = 0;
  bool hasError = false;

  Future<void> getSpices() async {
    // print("getSpices()");
    // if (!spices.contains((String element) => element.compareTo(name) == 0)) {
    //   spices.insert(0, name);
    // }
    List<Spice> _l = await SpiceDB.instance.readAllSpices();
    List<String> _s = _l.map((e) => e.name).toList();
    _s.removeWhere((element) =>
        (element.compareTo(name) != 0) &&
        IngredientSelector.usedSpices.contains(element));
    // If current name isn't in list, add it to the beginning
    if (!_s.contains(this.name)) {
      _s.insert(0, name);
      if (name.isNotEmpty) {
        print("SPICE NO LONGER IN SYSTEM");
        hasError = true;
      }
    }
    // If list changed, call setState
    for (var x in spices) {
      if (!_s.contains((String element) => element.compareTo(x) == 0)) {
        setState(() {
          spices = _s;
        });
        return;
      }
    }
    for (var x in _s) {
      if (!spices.contains((String element) => element.compareTo(x) == 0)) {
        setState(() {
          spices = _s;
        });
        return;
      }
    }
  }

  String getName() {
    return name;
  }

  @override
  void initState() {
    super.initState();
    name = widget.name ?? '';
    amount = widget.amount ?? 0;
    // Add a blank value to dropdown list
    if (!spices.contains((String element) => element.compareTo(name) == 0)) {
      spices.insert(0, name);
    }
    getSpices();
    // print("Spices from init: $spices");
  }

  @override
  Widget build(BuildContext context) {
    // print("Build");
    // if (name.compareTo('') != 0) {
    //   print("Building for $name");
    // }
    // print("Spices from build: $spices");
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 200),
            child: DropdownButtonFormField(
              items: spices.map((spice) {
                return DropdownMenuItem(value: spice, child: Text('$spice'));
              }).toList(),
              value: name,
              style: TextStyle(fontSize: 22, color: Colors.black),
              onChanged: (String? newVal) {
                setState(() {
                  IngredientSelector.usedSpices.remove(this.name);
                  IngredientSelector.usedSpices.add(newVal!);
                  name = newVal;
                  widget.name = name;
                  // print("Name = $name");
                });
              },
              isDense: true,
              decoration: InputDecoration(
                labelText: "Spice",
                labelStyle: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                showError(),
                ElevatedButton(
                  onPressed: _getAmount,
                  child: _displayAmount(),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) => mainColor),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                ElevatedButton(
                  onPressed: () {
                    // print("Clicked delete for $name");
                    IngredientSelector.usedSpices
                        .removeWhere((element) => element.compareTo(name) == 0);
                    widget.removeFunction(widget.key!);
                  },
                  child: Text("Delete"),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) => Colors.red)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget showError() {
    if (hasError) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "This spice is not registered and can't be dispensed",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    // textAlign: TextAlign.center,
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              Icons.report_problem_outlined,
              size: 35,
              color: Colors.amber,
            )),
      );
    } else {
      return SizedBox();
    }
  }

  Text _displayAmount() {
    // print("_displayAmount()");
    // print("Amount = $amount");
    if (amount == 0) {
      return Text("Amount");
    } else {
      // Decide whether to show in tsp or tbsp
      if (unit == 0) {
        return Text("${(amount / 4).toStringAsFixed(2)} tsp");
      }
      if (unit == 1) {
        return Text("${(amount / 4 / 3).toStringAsFixed(2)} tbsp");
      }
      return Text("Amount");
    }
  }

  Future<void> _getAmount() async {
    dynamic result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AmountPage(dispense: false)));
    // print("Result: $result");
    // print("Type: ${result.runtimeType}");
    if (result != null &&
        result.runtimeType.toString().compareTo("List<int>") == 0) {
      unit = result[0];
      amount = result[1];
      widget.amount = amount;
      setState(() {});
    }
  }
}
