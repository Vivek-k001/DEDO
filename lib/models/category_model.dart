/// A data model representing a category, typically used for organizing tasks or items.
/// Stores an [id], a [name], and a [color] (stored as an int).
class CategoryModel {
  final String id;     // Unique identifier for the category.
  final String name;   // Display name of the category.
  final int color;     // Color code associated with the category (stored as ARGB int).

  /// Creates a [CategoryModel] with required [id], [name], and [color].
  const CategoryModel({
    required this.id,
    required this.name,
    required this.color,
  });

  /// Converts the [CategoryModel] into a map, typically used for storing in databases or serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  /// Creates a [CategoryModel] instance from a map, useful when reading from databases or APIs.
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }
}
