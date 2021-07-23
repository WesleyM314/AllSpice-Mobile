import 'package:allspice_mobile/models/ingredient.dart';
import 'package:allspice_mobile/models/recipe.dart';
import 'package:allspice_mobile/models/spice.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SpiceDB {
  static final SpiceDB instance = SpiceDB._init();

  static Database? _database;

  SpiceDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('spices.db');
    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final boolType = 'BOOLEAN NOT NULL';
    final intType = 'INTEGER NOT NULL';
    final strType = 'VARCHAR(25) NOT NULL';

    await db.execute('''
    CREATE TABLE $tableSpices (
    ${SpiceFields.id} $idType,
    ${SpiceFields.container} $intType,
    ${SpiceFields.name} $strType,
    ${SpiceFields.favorite} $boolType,
    ${SpiceFields.low} $boolType
    );
    ''');
    print("Created spice table");
    await db.execute('''
    CREATE TABLE $tableRecipes (
    ${RecipeFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${RecipeFields.name} VARCHAR(50) NOT NULL,
    ${RecipeFields.favorite} BOOLEAN NOT NULL
    )
    ''');
    print("Created recipe table");
    await db.execute('''
    CREATE TABLE $tableIngredients (
    ${IngredientFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${IngredientFields.name} VARCHAR(25) NOT NULL,
    ${IngredientFields.amount} INTEGER,
    ${IngredientFields.recipeId} INTEGER,
    FOREIGN KEY(${IngredientFields.recipeId}) REFERENCES $tableRecipes(${RecipeFields.id})
    )
    ''');
    print("Created ingredients table");
  }

  Future<Spice> createSpice(Spice spice) async {
    final db = await instance.database;
    final id = await db.insert(tableSpices, spice.toJson());
    return spice.copy(id: id);
  }

  Future<Recipe> createRecipe(Recipe recipe) async {
    final db = await instance.database;
    // Create recipe entry
    final _id = await db.insert(tableRecipes, recipe.toJson());
    List<Ingredient> ing = [];
    print("Adding ingredients to DB");

    await Future.forEach(recipe.ingredients!, (Ingredient i) async {
      Ingredient cur = i.copy(recipeId: _id);
      print("Cur ingredient: ${cur.toJson()}");
      final _ = await db.insert(tableIngredients, cur.toJson());
      print("Adding ${cur.name} to ing");
      ing.add(cur);
    });

    print("ing:");
    ing.forEach((element) {
      print(element.toJson());
    });
    // When done adding ingredients, copy recipe and return
    return recipe.copy(id: _id, ingredients: ing);
  }

  Future<List<Recipe>> readAllRecipes() async {
    final db = await instance.database;
    final orderBy =
        '${RecipeFields.favorite} DESC, ${RecipeFields.name} COLLATE NOCASE ASC';
    // First get all recipes
    final recResults = await db.query(tableRecipes, orderBy: orderBy);
    // Return list of recipes
    return await getRecipeIngredients(
        recResults.map((json) => Recipe.fromJson(json)).toList());
  }

  Future<List<Ingredient>> readAllIngredients() async {
    final db = await instance.database;

    final orderBy = '${IngredientFields.id} ASC';
    final result = await db.query(tableIngredients, orderBy: orderBy);
    return result.map((e) => Ingredient.fromJson(e)).toList();
  }

  Future<List<Recipe>> getRecipeIngredients(List<Recipe> r) async {
    final db = await instance.database;
    final orderBy = '${IngredientFields.name} COLLATE NOCASE ASC';

    await Future.forEach(r, (Recipe element) async {
      final result = await db.query(
        tableIngredients,
        orderBy: orderBy,
        where: '${IngredientFields.recipeId} = ?',
        whereArgs: [element.id],
      );
      element.setIngredients(
          result.map((json) => Ingredient.fromJson(json)).toList());
    });
    return r;
    // return result.map((e) => Ingredient.fromJson(e)).toList();
  }

  Future<Spice> readSpice(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableSpices,
      columns: SpiceFields.values,
      where: '${SpiceFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Spice.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Spice>> readAllSpices() async {
    final db = await instance.database;
    final orderBy =
        '${SpiceFields.favorite} DESC, ${SpiceFields.name} COLLATE NOCASE ASC';
    final result = await db.query(tableSpices, orderBy: orderBy);
    return result.map((json) => Spice.fromJson(json)).toList();
  }

  Future<List> readContainers() async {
    final db = await instance.database;
    final result = await db.query(
      tableSpices,
      columns: [SpiceFields.container],
    );

    if (result.isNotEmpty) {
      return result.map((e) => e['${SpiceFields.container}']).toList();
    } else {
      return [];
    }
  }

  Future<int> updateSpice(Spice spice) async {
    final db = await instance.database;

    return db.update(
      tableSpices,
      spice.toJson(),
      where: '${SpiceFields.id} = ?',
      whereArgs: [spice.id],
    );
  }

  Future<int> updateIngredient(Ingredient ing) async {
    final db = await instance.database;

    return db.update(
      tableIngredients,
      ing.toJson(),
      where: '${IngredientFields.id} = ?',
      whereArgs: [ing.id],
    );
  }

  Future<int> updateRecipe(Recipe recipe) async {
    final db = await instance.database;

    // Remove current spices associated with recipe
    await db.delete(
      tableIngredients,
      where: '${IngredientFields.recipeId} = ?',
      whereArgs: [recipe.id],
    );

    List<Ingredient> ing = [];
    // Add recipe's current ingredients
    await Future.forEach(recipe.ingredients!, (Ingredient i) async {
      Ingredient cur = i.copy(recipeId: recipe.id);
      print("Cur ingredient: ${cur.toJson()}");
      final _ = await db.insert(tableIngredients, cur.toJson());
      print("Adding ${cur.name} to ing");
      ing.add(cur);
    });

    recipe = recipe.copy(ingredients: ing);

    return db.update(
      tableRecipes,
      recipe.toJson(),
      where: '${RecipeFields.id} = ?',
      whereArgs: [recipe.id],
    );
  }

  Future<int> deleteSpice(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableSpices,
      where: '${SpiceFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecipe(int id) async {
    final db = await instance.database;
    // First delete all ingredients
    await db.delete(
      tableIngredients,
      where: '${IngredientFields.recipeId} = ?',
      whereArgs: [id],
    );

    // Then delete recipe
    return await db.delete(
      tableRecipes,
      where: '${RecipeFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
