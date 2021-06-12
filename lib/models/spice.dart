final String tableSpices = 'spices';

class SpiceFields {
  static final List<String> values = [id, name, container, favorite];

  static final String id = '_id';
  static final String name = 'name';
  static final String container = 'container';
  static final String favorite = 'favorite';
}

class Spice {
  int? id;
  String name;
  int container;
  bool favorite;

  Spice({
    this.id,
    required this.name,
    required this.container,
    this.favorite = false,
  });

  Spice copy({
    int? id,
    String? name,
    int? container,
    bool? favorite,
  }) =>
      Spice(
          id: id ?? this.id,
          name: name ?? this.name,
          container: container ?? this.container,
          favorite: favorite ?? this.favorite);

  static Spice fromJson(Map<String, Object?> json) => Spice(
        id: json[SpiceFields.id] as int?,
        name: json[SpiceFields.name] as String,
        container: json[SpiceFields.container] as int,
        favorite: json[SpiceFields.favorite] == 1,
      );

  Map<String, Object?> toJson() => {
        SpiceFields.id: id,
        SpiceFields.name: name,
        SpiceFields.container: container,
        SpiceFields.favorite: favorite ? 1 : 0,
      };
}
