final String tableIngredients = 'ingredients';

class IngredientFields {
  static final List<String> values = [id, name, recipeId, amount];

  static final String id = '_id';
  static final String name = 'name';
  static final String recipeId = 'recipeId';
  static final String amount = 'amount';
}

class Ingredient {
  int? id;
  String name;
  int? recipeId;
  int amount;

  Ingredient({
    this.id,
    required this.name,
    this.recipeId,
    required this.amount,
  });

  Ingredient copy({
    int? id,
    String? name,
    int? recipeId,
    int? amount,
  }) =>
      Ingredient(
        id: id ?? this.id,
        name: name ?? this.name,
        recipeId: recipeId ?? this.recipeId,
        amount: amount ?? this.amount,
      );

  static Ingredient fromJson(Map<String, Object?> json) => Ingredient(
        id: json[IngredientFields.id] as int?,
        name: json[IngredientFields.name] as String,
        recipeId: json[IngredientFields.recipeId] as int?,
        amount: json[IngredientFields.amount] as int,
      );

  Map<String, Object?> toJson() => {
        IngredientFields.id: id,
        IngredientFields.name: name,
        IngredientFields.recipeId: recipeId,
        IngredientFields.amount: amount,
      };
}
