import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Recipe {
  final String name;
  final String category;
  final List<Map<String, dynamic>> ingredients;
  final List<String> steps;
  final XFile? imageFile;

  Recipe({
    required this.name,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.imageFile,
  });
}

class BakeLog {
  final String date;
  final String ingredientChanges;
  final String methodChanges;
  final String resultsNotes;

  BakeLog({
    required this.date,
    required this.ingredientChanges,
    required this.methodChanges,
    required this.resultsNotes,
  });
}

class RecipeProvider extends ChangeNotifier {
  final List<Recipe> _recipes = [];
  final List<String> _categories = ['breads', 'cakes', 'cookies'];
  final Map<String, List<String>> _notes = {};
  final Map<String, List<BakeLog>> _logs = {};

  List<Recipe> get recipes => _recipes;
  List<String> get categories => _categories;

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  void removeCategory(String category) {
    _categories.remove(category);
    notifyListeners();
  }

  void addNoteToItem(String itemName, String note) {
    if (!_notes.containsKey(itemName)) {
      _notes[itemName] = [];
    }
    _notes[itemName]!.add(note);
    notifyListeners();
  }

  List<String> getNotes(String itemName) {
    return _notes[itemName] ?? [];
  }

  void addLog(String recipeName, BakeLog log) {
    if (!_logs.containsKey(recipeName)) {
      _logs[recipeName] = [];
    }
    _logs[recipeName]!.add(log);
    notifyListeners();
  }

  List<BakeLog> getLogs(String recipeName) {
    return _logs[recipeName] ?? [];
  }
}
