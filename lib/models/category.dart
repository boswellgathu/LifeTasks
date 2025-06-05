class Category {
  final String id;
  final String name;
  final String colorHex;
  final bool isUserDefined;

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
    this.isUserDefined = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'is_user_defined': isUserDefined ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorHex: map['color_hex'],
      isUserDefined: map['is_user_defined'] == 1,
    );
  }
}