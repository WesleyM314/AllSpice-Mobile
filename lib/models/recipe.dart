import 'package:allspice_mobile/models/ingredient.dart';

final String tableRecipes = 'recipes';

class RecipeFields {
  static final List<String> values = [id, name];

  static final String id = '_id';
  static final String name = 'name';
  static final String ingredients = 'ingredients';
  static final String favorite = 'favorite';
}

class Recipe {
  int? id;
  String name;
  // List<String>? ingredientNames;
  // Map<String, int>? ingredients;
  List<Ingredient>? ingredients;
  bool favorite;

  Recipe({
    this.id,
    required this.name,
    this.ingredients,
    this.favorite = false,
  });

  Recipe copy({
    int? id,
    String? name,
    List<Ingredient>? ingredients,
    bool? favorite,
  }) =>
      Recipe(
          id: id ?? this.id,
          name: name ?? this.name,
          ingredients: ingredients ?? this.ingredients,
          favorite: favorite ?? this.favorite);

  void setIngredients(List<Ingredient> i) {
    this.ingredients = i;
  }

  void addIngredient(Ingredient i) {
    this.ingredients?.add(i);
  }

  static Recipe fromJson(Map<String, Object?> json) => Recipe(
        id: json[RecipeFields.id] as int?,
        name: json[RecipeFields.name] as String,
        favorite: json[RecipeFields.favorite] == 1,
      );

  // Output json of just the recipe name and id
  Map<String, Object?> toJson() => {
        RecipeFields.id: id,
        RecipeFields.name: name,
        RecipeFields.favorite: favorite ? 1 : 0,
      };
}
