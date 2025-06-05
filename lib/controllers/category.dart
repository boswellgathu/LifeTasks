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

  // Load all categories
  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _categoryRepository.getAllCategories();
      _error = null;
    } catch (e) {
      _error = 'Failed to load categories';
    } finally {
      _setLoading(false);
    }
  }

  // Add a new category
  Future<void> addCategory(Category category) async {
    try {
      await _categoryRepository.insertCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add category';
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoryRepository.deleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete category';
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}