import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String creator;
  final List<String> ingredients;
  final List<String> steps;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.creator,
    required this.ingredients,
    required this.steps,
    this.isFavorite = true,
  });
}

class FavoritePage extends StatelessWidget {
  final List<Recipe> favoriteRecipes = [
    Recipe(
      title: 'Gado gado Entong',
      description: 'Gado-gado adalah salah satu makanan khas Indonesia.',
      imageUrl: 'https://nibble-images.b-cdn.net/nibble/original_images/gado_gado_enak_di_jakarta_03_515ab09c9d.jpg',
      creator: 'Entong ganteng',
      ingredients: [
        '100g lontong',
        '50g kacang tanah',
        '50g sayuran',
        '3 telur rebus',
        '350g saus kacang',
        '2 cabai',
        '50g kerupuk',
      ],
      steps: [
        'Step 1: Siapkan bahan-bahan.',
        'Step 2: Rebus sayuran dan telur.',
        'Step 3: Campur semua bahan dengan saus kacang.',
      ],
    ),
    Recipe(
      title: 'Nasi Goreng Toyib',
      description: 'Nasi Goreng adalah makanan khas Indonesia yang lezat.',
      imageUrl: 'https://example.com/nasigoreng.jpg',
      creator: 'Toyib cakep',
      ingredients: [
        '2 cups cooked rice',
        '2 tablespoons oil',
        '1 onion, chopped',
        '2 cloves garlic, minced',
        '100g chicken, diced',
        '2 eggs, beaten',
        '1 tablespoon soy sauce',
        'Salt and pepper to taste',
      ],
      steps: [
        'Step 1: Heat oil in a pan.',
        'Step 2: Sauté onion and garlic.',
        'Step 3: Add chicken and cook until done.',
        'Step 4: Add cooked rice and stir well.',
        'Step 5: Push rice to the side and scramble the eggs.',
        'Step 6: Mix everything together and add soy sauce.',
        'Step 7: Season with salt and pepper.',
      ],
    ),
    // Tambahkan 8 resep lainnya dengan cara yang sama
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: EdgeInsets.all(10.0),
            elevation: 5.0,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipe)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: recipe.imageUrl,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      child: Image.network(
                        recipe.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              recipe.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: recipe.isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                // Handle favorite button press
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          recipe.description,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'By ${recipe.creator}',
                          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: recipe.imageUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  recipe.imageUrl,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              recipe.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'By ${recipe.creator}',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16.0),
            Text(
              recipe.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ...recipe.ingredients
                .map((ingredient) => Text('• $ingredient'))
                .toList(),
            SizedBox(height: 16.0),
            Text(
              'Steps',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ...recipe.steps
                .map((step) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(step),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
