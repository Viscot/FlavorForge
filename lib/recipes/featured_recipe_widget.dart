import 'package:flutter/material.dart';

class Recipe {
  final String name;
  final String imageUrl;
  final String description;

  Recipe({required this.name, required this.imageUrl, required this.description});
}

class FeaturedRecipeWidget extends StatelessWidget {
  final List<Recipe> recipes = [
    Recipe(name: 'Spaghetti Carbonara', imageUrl: 'https://assets.tmecosys.com/image/upload/t_web767x639/img/recipe/ras/Assets/0346a29a89ef229b1a0ff9697184f944/Derivates/cb5051204f4a4525c8b013c16418ae2904e737b7.jpg', description: 'Delicious spaghetti with creamy sauce and bacon.'),
    Recipe(name: 'Chicken Alfredo', imageUrl: 'https://www.budgetbytes.com/wp-content/uploads/2022/07/Chicken-Alfredo-above-500x500.jpg', description: 'Creamy pasta dish with chicken and parmesan cheese.'),
    Recipe(name: 'Margherita Pizza', imageUrl: 'https://kitchenswagger.com/wp-content/uploads/2023/05/margherita-pizza-close.jpg', description: 'Classic Italian pizza with tomatoes, mozzarella, and basil.'),
    Recipe(name: 'Caesar Salad', imageUrl: 'https://heartbeetkitchen.com/foodblog/wp-content/uploads/2022/06/ultimate-grilled-chicken-caesar-salad.jpg', description: 'Fresh salad with romaine lettuce, croutons, parmesan cheese, and Caesar dressing.'),
    Recipe(name: 'Tacos', imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT-O-lOivV3yivl1ggvEVVH28EMmhLnxe2Pqg&s', description: 'Mexican dish consisting of corn or wheat tortillas folded or rolled around a filling.'),
    Recipe(name: 'Sushi', imageUrl: 'https://example.com/sushi.jpg', description: 'Japanese dish consisting of vinegared rice combined with various ingredients such as seafood, vegetables, and occasionally tropical fruits.'),
    Recipe(name: 'Pancakes', imageUrl: 'https://example.com/pancakes.jpg', description: 'Flat cake, often thin and round, prepared from a starch-based batter that may contain eggs, milk, and butter.'),
    Recipe(name: 'Burger', imageUrl: 'https://example.com/burger.jpg', description: 'Sandwich consisting of a cooked patty of ground meat, usually beef, placed inside a sliced bread roll or bun.'),
    Recipe(name: 'Lasagna', imageUrl: 'https://example.com/lasagna.jpg', description: 'Pasta dish made with several layers of lasagna sheets alternating with sauces and various other ingredients such as meats, vegetables, and cheese.'),
    Recipe(name: 'Ice Cream', imageUrl: 'https://example.com/icecream.jpg', description: 'Sweetened frozen food typically eaten as a snack or dessert.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipes[index])),
              );
            },
            child: RecipeCard(recipe: recipes[index]),
          );
        },
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Menyesuaikan lebar kotak resep
      margin: EdgeInsets.only(right: 16), // Menambahkan jarak antara kotak resep
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 120, // Menyesuaikan tinggi gambar
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                image: DecorationImage(
                  image: NetworkImage(recipe.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () {
                        // Action when like button is pressed
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    recipe.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
                      );
                    },
                    child: Text('Recipe Detail'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(recipe.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              recipe.description,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
