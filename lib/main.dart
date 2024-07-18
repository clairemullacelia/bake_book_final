import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RecipeProvider(),
      child: MaterialApp(
        title: 'bakebook',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'recipes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'categories',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RecipesPage(),
            CategoriesPage(),
          ],
        ),
      ),
    );
  }
}

class RecipesPage extends StatelessWidget {
  const RecipesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipes = Provider.of<RecipeProvider>(context).recipes;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'search recipes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: const Icon(Icons.mic),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddRecipePage()),
                    );
                  },
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  leading: recipe.imageFile != null
                      ? Image.file(File(recipe.imageFile!.path))
                      : const Icon(Icons.image),
                  title: Text(recipe.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<RecipeProvider>(context).categories;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryRecipesPage(category: category),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Provider.of<RecipeProvider>(context, listen: false).removeCategory(category);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('add category'),
              onPressed: () {
                _showAddCategoryDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final category = categoryController.text.trim();
                if (category.isNotEmpty) {
                  Provider.of<RecipeProvider>(context, listen: false).addCategory(category);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({Key? key}) : super(key: key);

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  late String recipeName;
  late String recipeCategory;
  XFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<RecipeProvider>(context).categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('add new recipe'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              if (imageFile != null) Image.file(File(imageFile!.path)),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('upload image'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'recipe name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please enter a recipe name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    recipeName = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'recipe category',
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please select a recipe category';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      recipeCategory = value!;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddIngredientsPage(
                          recipeName: recipeName,
                          recipeCategory: recipeCategory,
                          imageFile: imageFile,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('add ingredients'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddIngredientsPage extends StatefulWidget {
  final String recipeName;
  final String recipeCategory;
  final XFile? imageFile;

  const AddIngredientsPage({
    Key? key,
    required this.recipeName,
    required this.recipeCategory,
    this.imageFile,
  }) : super(key: key);

  @override
  _AddIngredientsPageState createState() => _AddIngredientsPageState();
}

class _AddIngredientsPageState extends State<AddIngredientsPage> {
  final List<Map<String, dynamic>> addedIngredients = [];
  final List<Map<String, dynamic>> ingredients = [
    {'name': 'ap flour', 'quantity': 0, 'unit': 'grams'},
    {'name': 'unsalted butter', 'quantity': 0, 'unit': 'grams'},
    {'name': 'eggs', 'quantity': 0, 'unit': 'grams'},
    {'name': 'whole milk', 'quantity': 0, 'unit': 'grams'},
    {'name': 'granulated sugar', 'quantity': 0, 'unit': 'grams'},
    {'name': 'heavy cream', 'quantity': 0, 'unit': 'grams'},
    {'name': 'powdered sugar', 'quantity': 0, 'unit': 'grams'},
    {'name': 'brown sugar', 'quantity': 0, 'unit': 'grams'},
    {'name': 'yogurt', 'quantity': 0, 'unit': 'grams'},
    {'name': 'baking powder', 'quantity': 0, 'unit': 'grams'},
    {'name': 'buttermilk', 'quantity': 0, 'unit': 'grams'},
    {'name': 'baking soda', 'quantity': 0, 'unit': 'grams'},
    {'name': 'vanilla', 'quantity': 0, 'unit': 'grams'}
  ];

  void _addIngredient(String name, String quantity, String unit) {
    setState(() {
      addedIngredients.add({'name': name, 'quantity': quantity, 'unit': unit});
    });
  }

  void _editIngredient(int index, String name, String quantity, String unit) {
    setState(() {
      addedIngredients[index] = {'name': name, 'quantity': quantity, 'unit': unit};
    });
  }

  void _showEditIngredientDialog(int index) {
    final ingredient = addedIngredients[index];
    final TextEditingController nameController = TextEditingController(text: ingredient['name']);
    final TextEditingController quantityController =
        TextEditingController(text: ingredient['quantity'].toString());
    final TextEditingController unitController = TextEditingController(text: ingredient['unit']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('edit ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ingredient name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'quantity'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'unit'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('save'),
              onPressed: () {
                _editIngredient(
                    index, nameController.text, quantityController.text, unitController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddedIngredients() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: addedIngredients
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                                '${entry.value['quantity']} ${entry.value['unit']} ${entry.value['name']}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showEditIngredientDialog(entry.key);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                addedIngredients.removeAt(entry.key);
                              });
                              Navigator.of(context).pop();
                              _showAddedIngredients();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddIngredientDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController(text: '100');
    final TextEditingController unitController = TextEditingController(text: 'grams');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('add ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ingredient name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'quantity'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'unit'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('add'),
              onPressed: () {
                _addIngredient(
                    nameController.text, quantityController.text, unitController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('add ingredients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('add ingredient'),
                    onPressed: _showAddIngredientDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: IngredientCard(
                      ingredient: ingredient,
                      onAdd: (ingredient) {
                        _addIngredient(ingredient['name'], ingredient['quantity'].toString(),
                            ingredient['unit']);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text('added ingredients'),
                  onPressed: _showAddedIngredients,
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('add method'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMethodPage(
                            recipeName: widget.recipeName,
                            recipeCategory: widget.recipeCategory,
                            imageFile: widget.imageFile,
                            addedIngredients: addedIngredients,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class IngredientCard extends StatefulWidget {
  final Map<String, dynamic> ingredient;
  final Function(Map<String, dynamic>) onAdd;

  const IngredientCard({
    Key? key,
    required this.ingredient,
    required this.onAdd,
  }) : super(key: key);

  @override
  _IngredientCardState createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  late String quantity;
  late String unit;

  @override
  void initState() {
    super.initState();
    quantity = widget.ingredient['quantity'].toString();
    unit = widget.ingredient['unit'];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.ingredient['name'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: quantity,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      quantity = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: unit,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      unit = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 30),
                onPressed: () {
                  widget.onAdd(
                      {'name': widget.ingredient['name'], 'quantity': quantity, 'unit': unit});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddMethodPage extends StatefulWidget {
  final String recipeName;
  final String recipeCategory;
  final XFile? imageFile;
  final List<Map<String, dynamic>> addedIngredients;

  const AddMethodPage({
    Key? key,
    required this.recipeName,
    required this.recipeCategory,
    this.imageFile,
    required this.addedIngredients,
  }) : super(key: key);

  @override
  _AddMethodPageState createState() => _AddMethodPageState();
}

class _AddMethodPageState extends State<AddMethodPage> {
  List<String> steps = [''];

  void _addStep() {
    setState(() {
      steps.add('');
    });
  }

  void _showAddedIngredients() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.addedIngredients
                  .map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                                '${ingredient['quantity']} ${ingredient['unit']} ${ingredient['name']}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showEditIngredientDialog(widget.addedIngredients.indexOf(ingredient));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                widget.addedIngredients.remove(ingredient);
                              });
                              Navigator.of(context).pop();
                              _showAddedIngredients();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditIngredientDialog(int index) {
    final ingredient = widget.addedIngredients[index];
    final TextEditingController nameController = TextEditingController(text: ingredient['name']);
    final TextEditingController quantityController =
        TextEditingController(text: ingredient['quantity'].toString());
    final TextEditingController unitController = TextEditingController(text: ingredient['unit']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('edit ingredient'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ingredient name'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'quantity'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'unit'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('save'),
              onPressed: () {
                setState(() {
                  widget.addedIngredients[index] = {
                    'name': nameController.text,
                    'quantity': quantityController.text,
                    'unit': unitController.text,
                  };
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveRecipe() {
    final recipe = Recipe(
      name: widget.recipeName,
      category: widget.recipeCategory,
      ingredients: widget.addedIngredients,
      steps: steps,
      imageFile: widget.imageFile,
    );
    Provider.of<RecipeProvider>(context, listen: false).addRecipe(recipe);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('add method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'add method',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: null,
                            onChanged: (value) {
                              steps[index] = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addStep,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text('view added ingredients'),
                    onPressed: _showAddedIngredients,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveRecipe,
                child: const Text('save recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.imageFile != null) Image.file(File(recipe.imageFile!.path)),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FixedColumnWidth(100),
                  1: FlexColumnWidth(),
                },
                children: recipe.ingredients.map((ingredient) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${ingredient['quantity']} ${ingredient['unit']}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(ingredient['name']),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.sticky_note_2),
                              onPressed: () {
                                _showNoteDialog(context, ingredient['name']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...recipe.steps.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key + 1}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.sticky_note_2),
                            onPressed: () {
                              _showNoteDialog(context, 'Step ${entry.key + 1}');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('recipes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeLogPage(recipeName: recipe.name),
                        ),
                      );
                    },
                    child: const Text('view log'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, String itemName) {
    final TextEditingController noteController = TextEditingController();
    final notes = Provider.of<RecipeProvider>(context, listen: false).getNotes(itemName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Notes for $itemName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var note in notes) Text(note),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Add a note'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final note = noteController.text.trim();
                if (note.isNotEmpty) {
                  Provider.of<RecipeProvider>(context, listen: false).addNoteToItem(itemName, note);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class RecipeLogPage extends StatelessWidget {
  final String recipeName;

  const RecipeLogPage({Key? key, required this.recipeName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<RecipeProvider>(context).getLogs(recipeName);

    return Scaffold(
      appBar: AppBar(
        title: Text('$recipeName log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogBakePage(recipeName: recipeName),
                  ),
                );
              },
              child: const Text('log bake'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    title: Text(log.date),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LogDetailPage(log: log),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogBakePage extends StatefulWidget {
  final String recipeName;

  const LogBakePage({Key? key, required this.recipeName}) : super(key: key);

  @override
  _LogBakePageState createState() => _LogBakePageState();
}

class _LogBakePageState extends State<LogBakePage> {
  final TextEditingController ingredientChangesController = TextEditingController();
  final TextEditingController methodChangesController = TextEditingController();
  final TextEditingController resultsNotesController = TextEditingController();
  final String currentDate = DateTime.now().toString().split(' ')[0];

  void _saveLog() {
    final log = BakeLog(
      date: currentDate,
      ingredientChanges: ingredientChangesController.text,
      methodChanges: methodChangesController.text,
      resultsNotes: resultsNotesController.text,
    );

    Provider.of<RecipeProvider>(context, listen: false).addLog(widget.recipeName, log);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeLogPage(recipeName: widget.recipeName),
      ),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Bake for ${widget.recipeName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Date: $currentDate'),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: ingredientChangesController,
                decoration: const InputDecoration(
                  labelText: 'ingredient changes',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: methodChangesController,
                decoration: const InputDecoration(
                  labelText: 'method changes',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: resultsNotesController,
                decoration: const InputDecoration(
                  labelText: 'results / notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveLog,
              child: const Text('save log'),
            ),
          ],
        ),
      ),
    );
  }
}

class LogDetailPage extends StatelessWidget {
  final BakeLog log;

  const LogDetailPage({Key? key, required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${log.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Ingredient Changes:'),
            Text(log.ingredientChanges),
            const SizedBox(height: 10),
            Text('Method Changes:'),
            Text(log.methodChanges),
            const SizedBox(height: 10),
            Text('Results / Notes:'),
            Text(log.resultsNotes),
          ],
        ),
      ),
    );
  }
}

class CategoryRecipesPage extends StatelessWidget {
  final String category;

  const CategoryRecipesPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recipes = Provider.of<RecipeProvider>(context)
        .recipes
        .where((recipe) => recipe.category == category)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            leading: recipe.imageFile != null
                ? Image.file(File(recipe.imageFile!.path))
                : const Icon(Icons.image),
            title: Text(recipe.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
              );
            },
          );
        },
      ),
    );
  }
}

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
