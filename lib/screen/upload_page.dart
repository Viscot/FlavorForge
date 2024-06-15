<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<TextEditingController> _instructionsController = [];
  List<TextEditingController> _ingredientControllers = [];
  File? _image;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadRecipe() async {
    if (_formKey.currentState!.validate()) {
      // Upload image to Firebase Storage
      String? imageUrl;
      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'recipe_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_image!);
        final snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      DocumentReference user = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      // Collect ingredients
      List<String> ingredients =
          _ingredientControllers.map((controller) => controller.text).toList();

      List<String> instructions =
          _instructionsController.map((controller) => controller.text).toList();

      _ingredientControllers.map((controller) => controller.text).toList();

      // Create a new recipe document
      await FirebaseFirestore.instance.collection('recipes').add({
        'title': _nameController.text,
        'description': _descriptionController.text,
        'instructions': instructions,
        'ingredients': ingredients,
        'imageUrl': imageUrl,
        'likesCount': 0,
        'commentsCount': 0,
        'authorId': user,
        'createdAt': Timestamp.now(),
      });

      // Clear the form
      _nameController.clear();
      _descriptionController.clear();
      _instructionsController.clear();
      _ingredientControllers.forEach((controller) => controller.clear());
      setState(() {
        _image = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe uploaded successfully')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _instructionsController) {
      controller.dispose();
    }
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Recipe'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.file(
                            _image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Recipe Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Recipe name cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Instructions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._instructionsController.map((controller) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: FadeTransition(
                      opacity: _animation,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: 'Intructions',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingredient cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _ingredientControllers.remove(controller);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _instructionsController.add(TextEditingController());
                      _animationController.forward(from: 0);
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Intructions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._ingredientControllers.map((controller) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: FadeTransition(
                      opacity: _animation,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: 'Ingredient',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingredient cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _ingredientControllers.remove(controller);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _ingredientControllers.add(TextEditingController());
                      _animationController.forward(from: 0);
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Ingredient'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _uploadRecipe,
                  child: Text('Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
=======
>>>>>>> d790979a9c28cf91d784d1936a9d515f14adc6d8
