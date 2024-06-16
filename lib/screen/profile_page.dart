import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flavorforge/screen/add_post.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileBody extends StatefulWidget {
  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  String _username = 'Usernames';
  String _email = 'example@gmail.com';
  String _gender = 'Laki-laki';
  int _followers = 1000;
  int _following = 500;

  List<Map<String, dynamic>> _myRecipes = [];
  List<Map<String, dynamic>> _myPosts = [];

  @override
  void initState() {
    getDataProfile();
    fetchUserRecipes();
    fetchUserPosts(); // Tambahkan ini
    super.initState();
  }

  void getDataProfile() async {
    print("get data profile");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _username = sharedPreferences.getString('username') ?? 'Usernames';
      _email = sharedPreferences.getString('userEmail') ?? 'example@gmail.com';
      _gender = sharedPreferences.getString('jenis_kelamin') ?? 'Laki-laki';
    });

    // Ambil data dari Firestore jika ada
    User? user = FirebaseAuth.instance.currentUser;

    print(user);

    if (user != null) {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      QuerySnapshot followedUser = await FirebaseFirestore.instance
          .collection('follows')
          .where('userId', isEqualTo: userRef)
          .get();

      QuerySnapshot followerUser = await FirebaseFirestore.instance
          .collection('follows')
          .where('followId', isEqualTo: userRef)
          .get();

      if (userDoc.exists) {
        print("ketemu");
        setState(() {
          _username = userDoc['username'] ?? 'Usernames';
          _email = userDoc['email'] ?? 'example@gmail.com';
          _gender = userDoc['jenis_kelamin'] ?? 'Laki-laki';
          _following = followedUser.size;
          _followers = followerUser.size;
        });
        // Simpan ke SharedPreferences
        sharedPreferences.setString('username', _username);
        sharedPreferences.setString('userEmail', _email);
        sharedPreferences.setString('jenis_kelamin', _gender);
      }
    }
  }

  Future<void> fetchUserRecipes() async {
    User? user = FirebaseAuth.instance.currentUser;

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);

    if (user != null) {
      QuerySnapshot recipeSnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .where('authorId', isEqualTo: userRef)
          .get();

      setState(() {
        _myRecipes = recipeSnapshot.docs.map((doc) {
          return {
            'id': doc.id, // store the document ID for later use
            'title': doc['title'],
            'description': doc['description'],
            'ingredients': List<String>.from(doc['ingredients']),
            'likes': doc['likesCount'],
          };
        }).toList();
      });
    }
  }

  Future<void> fetchUserPosts() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);
    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userRef)
        .get();

    setState(() {
      _myPosts = postSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'imageUrl': doc['imageUrl'],
          'caption': doc['caption'],
          'tags': List<String>.from(doc['tags']),
          'createdAt': doc['createdAt'],
          'likesCount': doc['likesCount'],
          'username': doc['username']
        };
      }).toList();
    });
  }

  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  Future<void> _openEditProfileDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
                controller: TextEditingController()..text = _username,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                controller: TextEditingController()..text = _email,
                readOnly: true,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: _gender,
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Perbarui profil di Firestore
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'username': _username,
                    'email': _email,
                    'jenis_kelamin': _gender,
                  });

                  // Simpan perubahan ke SharedPreferences
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.setString('username', _username);
                  sharedPreferences.setString('userEmail', _email);
                  sharedPreferences.setString('jenis_kelamin', _gender);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditRecipeDialog(int index, VoidCallback update) async {
    String newTitle = _myRecipes[index]['title'];
    String newDescription = _myRecipes[index]['description'];
    List<String> newIngredients =
        List<String>.from(_myRecipes[index]['ingredients']);

    TextEditingController titleController = TextEditingController()
      ..text = newTitle;
    TextEditingController descriptionController = TextEditingController()
      ..text = newDescription;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Recipe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: 'Title'),
                      onChanged: (value) {
                        newTitle = value;
                      },
                      controller: titleController,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Description'),
                      onChanged: (value) {
                        newDescription = value;
                      },
                      controller: descriptionController,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ingredients:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: newIngredients.map((ingredient) {
                        return ListTile(
                          title: Text(ingredient),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                newIngredients.remove(ingredient);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        setState(() {
                          _myRecipes[index]['title'] = newTitle;
                          _myRecipes[index]['description'] = newDescription;
                          _myRecipes[index]['ingredients'] = newIngredients;
                        });

                        // Perbarui resep di Firestore
                        await FirebaseFirestore.instance
                            .collection('recipes')
                            .doc(_myRecipes[index]['id'])
                            .update({
                          'title': newTitle,
                          'description': newDescription,
                          'ingredients': newIngredients,
                        });
                        update();
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openDeleteRecipeDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Recipe'),
          content: Text('Are you sure you want to delete this recipe?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Hapus resep dari Firestore
                await FirebaseFirestore.instance
                    .collection('recipes')
                    .doc(_myRecipes[index]['id'])
                    .delete();

                setState(() {
                  _myRecipes.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  bool updateSc = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            child: Text(
              "${_username.characters.first.toUpperCase()}${_username.characters.last.toUpperCase()}",
              style: TextStyle(fontSize: 25),
            ),
          ),
          SizedBox(height: 20),
          Text(
            textAlign: TextAlign.center,
            _username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            textAlign: TextAlign.center,
            _email,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          Text(
            textAlign: TextAlign.center,
            'Jenis Kelamin: $_gender',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: [
                  Text(
                    'Followers',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$_followers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    'Following',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$_following',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _openEditProfileDialog,
            child: Text('Edit Profile'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddPost(
                  user: FirebaseAuth.instance.currentUser!,
                ),
              ));
            },
            child: Text('Add Post'),
          ),
          SizedBox(height: 10),
          Text(
            textAlign: TextAlign.center,
            'My Recipes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _myRecipes.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  title: Text(_myRecipes[index]['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(_myRecipes[index]['description']),
                      Text('Likes: ${_myRecipes[index]['likes']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _openEditRecipeDialog(
                            index,
                            () {
                              setState(() {
                                updateSc != updateSc;
                              });
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _openDeleteRecipeDialog(index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Text(
            textAlign: TextAlign.center,
            'My Post',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _myPosts.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(_myPosts[index]['username']
                                .toString()
                                .characters
                                .first
                                .toUpperCase() +
                            _myPosts[index]['username']
                                .toString()
                                .characters
                                .last
                                .toUpperCase()),
                      ),
                      title: Text(_myPosts[index]['username']),
                    ),
                    _myPosts[index]['imageUrl'] != null
                        ? Image.network(
                            _myPosts[index]['imageUrl'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                          )
                        : SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _myPosts[index]['caption'],
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Tags: ${_myPosts[index]['tags'].join(', ')}',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Row(
                            children: [
                              Icon(Icons.favorite),
                              Text(_myPosts[index]['likesCount'].toString())
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
