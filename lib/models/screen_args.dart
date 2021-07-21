import 'package:allspice_mobile/models/recipe.dart';
import 'package:allspice_mobile/models/spice.dart';

class ScreenArgs {
  final List<Spice> spices;
  final List<Recipe> recipes;

  ScreenArgs(this.spices, this.recipes);
}
