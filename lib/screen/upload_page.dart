import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<TextEditingController> _ingredientControllers = [];
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_image != null)
                  Image.file(_image!)
                else
                  Placeholder(
                    fallbackHeight: 200.0,
                  ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Ambil Foto'),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Makanan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama makanan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Bahan-bahan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ..._ingredientControllers.map((controller) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Bahan',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Bahan tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _ingredientControllers.remove(controller);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _ingredientControllers.add(TextEditingController());
                    });
                  },
                  child: Text('Tambah Bahan'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle form submission
                      print('Nama Makanan: ${_nameController.text}');
                      print('Deskripsi: ${_descriptionController.text}');
                      _ingredientControllers.forEach((controller) {
                        print('Bahan: ${controller.text}');
                      });
                      if (_image != null) {
                        print('Image Path: ${_image!.path}');
                      }
                    }
                  },
                  child: Text('Upload'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
