import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPost extends StatefulWidget {
  final User user;

  const AddPost({Key? key, required this.user}) : super(key: key);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  TextEditingController _captionController = TextEditingController();
  TextEditingController _tagController = TextEditingController();
  List<String> _tags = [];
  bool _isLoading = false;

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('posts/$fileName');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  Future<void> _uploadPost() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = await _uploadImage(_imageFile!);

      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc();

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.user.uid);

      DocumentSnapshot userSnap = await userRef.get();

      await postRef.set({
        'username': userSnap['username'],
        'userId': userRef,
        'imageUrl': imageUrl,
        'caption': _captionController.text,
        'tags': _tags,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully')),
      );

      setState(() {
        _imageFile = null;
        _captionController.clear();
        _tagController.clear();
        _tags.clear();
      });
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Postingan',
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _getImage,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.withOpacity(0.3),
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black45,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Tambahkan keterangan...',
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan tagar...',
                        labelText: 'Tagar',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _tags.add(value);
                          _tagController.clear();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _tags.add(_tagController.text);
                        _tagController.clear();
                      });
                    },
                    child: Text(
                      'Tambah',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children:
                    _tags.map((tag) => Chip(label: Text('#$tag'))).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadPost,
                child: Text(
                  'Upload',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

