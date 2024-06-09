import 'package:flutter/material.dart';

class TrendingRecipesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> trendingRecipes = [
    {
      'imageUrl': 'https://example.com/image1.jpg',
      'author': 'John Doe',
      'title': 'Delicious Chicken Curry',
      'description': 'A savory curry dish that will tantalize your taste buds.',
      'likes': 120,
    },
    {
      'imageUrl': 'https://example.com/image2.jpg',
      'author': 'Jane Smith',
      'title': 'Classic Chocolate Cake',
      'description': 'Indulge in the rich flavors of this timeless dessert.',
      'likes': 98,
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
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                          // Add navigation to recipe details page
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
