final String tableSpices = 'spices';

class SpiceFields {
  static final List<String> values = [id, name, container, favorite];

  static final String id = '_id';
  static final String name = 'name';
  static final String container = 'container';
  static final String favorite = 'favorite';
  static final String low = 'low';
}

class Spice {
  int? id;
  String name;
  int container;
  bool favorite;
  bool low;

  Spice({
    this.id,
    required this.name,
    required this.container,
    this.favorite = false,
    this.low = false,
  });

  Spice copy({
    int? id,
    String? name,
    int? container,
    bool? favorite,
    bool? low,
  }) =>
      Spice(
          id: id ?? this.id,
          name: name ?? this.name,
          container: container ?? this.container,
          favorite: favorite ?? this.favorite,
          low: low ?? this.low);

  static Spice fromJson(Map<String, Object?> json) => Spice(
        id: json[SpiceFields.id] as int?,
        name: json[SpiceFields.name] as String,
        container: json[SpiceFields.container] as int,
        favorite: json[SpiceFields.favorite] == 1,
        low: json[SpiceFields.low] == 1,
      );

  Map<String, Object?> toJson() => {
        SpiceFields.id: id,
        SpiceFields.name: name,
        SpiceFields.container: container,
        SpiceFields.favorite: favorite ? 1 : 0,
        SpiceFields.low: low ? 1 : 0,
      };
}
