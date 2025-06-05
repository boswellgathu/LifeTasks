import 'package:flutter/material.dart';
import '../models/category.dart';
import '../repositories/category.dart';

class CategoryController with ChangeNotifier {
  final CategoryRepository _categoryRepository = CategoryRepository();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _categoryRepository.getAllCategories();

      if (_categories.isEmpty) {
        await seedDefaultCategories(); // <--- CALL seeding if empty
        _categories = await _categoryRepository.getAllCategories(); // reload
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load categories';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _categoryRepository.insertCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add category';
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoryRepository.deleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete category';
    }
  }
  
  Future<void> seedDefaultCategories() async {
    await addCategory(Category(
      id: 'home',
      name: 'Home',
      colorHex: '#FFC107',
      iconCode: Icons.home.codePoint,
      iconFontFamily: Icons.home.fontFamily!,
    ));

    await addCategory(Category(
      id: 'repairs',
      name: 'Repairs',
      colorHex: '#2196F3',
      iconCode: Icons.build.codePoint,
      iconFontFamily: Icons.build.fontFamily!,
    ));

    await addCategory(Category(
      id: 'reminder',
      name: 'Reminder',
      colorHex: '#4CAF50',
      iconCode: Icons.notifications.codePoint,
      iconFontFamily: Icons.notifications.fontFamily!,
    ));
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}