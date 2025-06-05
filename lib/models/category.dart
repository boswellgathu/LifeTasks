import 'package:flutter/cupertino.dart';

class Category {
  final String id;
  final String name;
  final String colorHex;
  final bool isUserDefined;
  final int iconCode;
  final String iconFontFamily;

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.iconCode,
    required this.iconFontFamily,
    this.isUserDefined = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon_code': iconCode,
      'icon_font_family': iconFontFamily,
      'is_user_defined': isUserDefined ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorHex: map['color_hex'],
      iconCode: map['icon_code'],
      iconFontFamily: map['icon_font_family'],
      isUserDefined: map['is_user_defined'] == 1,
    );
  }

  IconData get iconData => IconData(iconCode, fontFamily: iconFontFamily);
}