import 'package:allspice_mobile/models/recipe.dart';
import 'package:allspice_mobile/models/recipe_card.dart';
import 'package:allspice_mobile/models/spice_db.dart';
import 'package:allspice_mobile/pages/add_edit_recipe_page.dart';
import 'package:flutter/material.dart';
import 'package:allspice_mobile/constants.dart';

class RecipePage extends StatefulWidget {
  final List<Recipe> recipes;
  const RecipePage({Key? key, required this.recipes}) : super(key: key);

  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> with AutomaticKeepAliveClientMixin {
  List<Recipe> recipeList = [];

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  Future refreshList() async {
    List<Recipe> _r = await SpiceDB.instance.readAllRecipes();
    setState(() {
      recipeList = _r;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: this.recipeList.isEmpty
          ? Center(
              child: Text(
                "Recipe Page",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            )
          : RefreshIndicator(
              child: ListView.builder(
                itemCount: this.recipeList.length,
                itemBuilder: (context, index) {
                  return RecipeCard(
                    recipe: this.recipeList[index],
                    refreshFunction: refreshList,
                  );
                },
                physics: const AlwaysScrollableScrollPhysics(),
              ),
              onRefresh: refreshList,
            ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        child: FittedBox(
          child: FloatingActionButton(
            heroTag: 'recipeBtn',
            child: Icon(
              Icons.add,
              size: 35,
            ),
            backgroundColor: mainColor,
            onPressed: _addRecipe,
          ),
        ),
      ),
    );
  }

  Future<void> _addRecipe() async {
    dynamic result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddEditRecipePage()));
    if (result != null) {
      refreshList();
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
