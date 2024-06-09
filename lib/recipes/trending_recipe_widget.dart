import 'package:flutter/material.dart';

class TrendingRecipesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> trendingRecipes = [
    {
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_S6UXUpqML7jn0aD8wpAOKEmS6Dsu8QkeYw&s',
      'author': 'Saipul Jamil',
      'title': 'Delicious Chicken Curry',
      'description': 'A savory curry dish that will tantalize your taste buds.',
      'likes': 1000,
      'ingredients': ['Chicken', 'Curry Powder', 'Coconut Milk'],
      'steps': ['Step 1: Prepare ingredients', 'Step 2: Cook chicken', 'Step 3: Add curry powder and coconut milk'],
    },
    {
      'imageUrl': 'https://joyfoodsunshine.com/wp-content/uploads/2020/08/best-chocolate-cake-recipe-from-scratch-8.jpg',
      'author': 'Ayu tingting',
      'title': 'Classic Chocolate Cake',
      'description': 'Indulge in the rich flavors of this timeless dessert.',
      'likes': 500,
      'ingredients': ['Flour', 'Sugar', 'Cocoa Powder', 'Eggs'],
      'steps': ['Step 1: Mix ingredients', 'Step 2: Bake in oven', 'Step 3: Let it cool and serve'],
    },
    // Add more recipes as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          itemCount: trendingRecipes.length,
          itemBuilder: (context, index) {
            final recipe = trendingRecipes[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      recipe['imageUrl'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recipe['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'by ${recipe['author']}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recipe['description'],
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${recipe['likes']} Likes',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                        child: Text('Details'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title']),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                recipe['imageUrl'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            SizedBox(height: 16),
            Text(
              recipe['title'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'by ${recipe['author']}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 16),
            Text(
              recipe['description'],
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Ingredients:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...recipe['ingredients'].map<Widget>((ingredient) {
              return Text('- $ingredient');
            }).toList(),
            SizedBox(height: 16),
            Text(
              'Steps:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...recipe['steps'].map<Widget>((step) {
              return Text('- $step');
            }).toList(),
          ],
        ),
      ),
    );
  }
}
