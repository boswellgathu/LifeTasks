import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/category.dart';
import '../models/category.dart';

class CategoryCreationScreen extends StatefulWidget {
  const CategoryCreationScreen({super.key});

  @override
  CategoryCreationScreenState createState() => CategoryCreationScreenState();
}

class CategoryCreationScreenState extends State<CategoryCreationScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  // Simple list of selectable icons (expandable later)
  final List<IconData> _availableIcons = [
    Icons.home,
    Icons.build,
    Icons.notifications,
    Icons.work,
    Icons.school,
    Icons.pets,
    Icons.shopping_cart,
    Icons.sports_soccer,
    Icons.fastfood,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category name is required')),
      );
      return;
    }

    final category = Category(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      colorHex: '#${_selectedColor.value.toRadixString(16).substring(2)}', // Convert to hex
      iconCode: _selectedIcon.codePoint,
      iconFontFamily: _selectedIcon.fontFamily!,
    );

    final categoryController = Provider.of<CategoryController>(context, listen: false);
    await categoryController.addCategory(category);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickColor() async {
    // Using a simple Color Picker Dialog
    Color? pickedColor = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              Navigator.of(context).pop(color);
            },
          ),
        ),
      ),
    );

    if (pickedColor != null) {
      setState(() {
        _selectedColor = pickedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            SizedBox(height: 20),
            Text('Pick a Color', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _pickColor,
              child: CircleAvatar(
                backgroundColor: _selectedColor,
                radius: 30,
              ),
            ),
            SizedBox(height: 20),
            Text('Pick an Icon', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _availableIcons.map((icon) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: _selectedIcon == icon ? _selectedColor : Colors.grey[300],
                    child: Icon(icon, color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveCategory,
              child: Text('Save Category'),
            ),
          ],
        ),
      ),
    );
  }
}