import 'package:flutter/material.dart';

class ProfileBody extends StatefulWidget {
  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  String _username = 'Username'; // Ganti dengan username Anda
  String _email = 'example@gmail.com'; // Ganti dengan alamat email Anda
  String _gender = 'Laki-laki'; // Ganti dengan jenis kelamin Anda
  int _followers = 1000; // Ganti dengan jumlah followers Anda
  int _following = 500; // Ganti dengan jumlah following Anda

  // List pilihan gender
  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  // Daftar resep
  final List<Map<String, dynamic>> _myRecipes = [
    {
      'title': 'Resep 1',
      'description': 'Deskripsi Resep 1',
      'ingredients': ['Bahan 1', 'Bahan 2', 'Bahan 3'],
      'likes': 20,
    },
    {
      'title': 'Resep 2',
      'description': 'Deskripsi Resep 2',
      'ingredients': ['Bahan 1', 'Bahan 2', 'Bahan 3'],
      'likes': 15,
    },
    {
      'title': 'Resep 3',
      'description': 'Deskripsi Resep 3',
      'ingredients': ['Bahan 1', 'Bahan 2', 'Bahan 3'],
      'likes': 10,
    },
  ];

  // Fungsi untuk membuka dialog edit profile
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
              onPressed: () {
                Navigator.of(context).pop();
                // Proses penyimpanan data bisa ditambahkan di sini
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membuka dialog edit resep
  Future<void> _openEditRecipeDialog(int index) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = _myRecipes[index]['title'];
        String newDescription = _myRecipes[index]['description'];
        List<String> newIngredients = List<String>.from(_myRecipes[index]['ingredients']);

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
                  controller: TextEditingController()..text = _myRecipes[index]['title'],
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    newDescription = value;
                  },
                  controller: TextEditingController()..text = _myRecipes[index]['description'],
                ),
                SizedBox(height: 10),
                Text(
                  'Ingredients:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Column(
                  children: newIngredients.map((ingredient) {
                    return Text('- ' + ingredient);
                  }).toList(),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _myRecipes[index]['title'] = newTitle;
                      _myRecipes[index]['description'] = newDescription;
                      _myRecipes[index]['ingredients'] = newIngredients;
                    });
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
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
              onPressed: () {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 20),
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/profile_picture.jpg'), // Ganti dengan gambar profil Anda
        ),
        SizedBox(height: 20),
        Text(
          _username,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          _email,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        SizedBox(height: 10),
        Text(
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
              children: <Widget>[
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
        Text(
          'My Recipes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: ListView.builder(
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
                          _openEditRecipeDialog(index);
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
        ),
      ],
    );
  }
}
