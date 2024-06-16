import 'package:flavorforge/recipes/featured_recipe_widget.dart';
import 'package:flavorforge/recipes/recipe_detail.dart';
import 'package:flavorforge/recipes/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrendingRecipesWidget extends StatefulWidget {
  @override
  _TrendingRecipesWidgetState createState() => _TrendingRecipesWidgetState();
}

class _TrendingRecipesWidgetState extends State<TrendingRecipesWidget> {
  List<Recipe> trendingRecipes = [];

  @override
  void initState() {
    super.initState();
    fetchTrendingRecipes();
  }

  void fetchTrendingRecipes() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .orderBy('likesCount', descending: true)
        .limit(2)
        .get();

    List<Recipe> recipes = [];

    // Use Future.wait to handle asynchronous fetching of author data
    await Future.wait(querySnapshot.docs.map((doc) async {
      DocumentReference authorRef =
          doc['authorId']; // Assume 'authorId' is a DocumentReference
      DocumentSnapshot authorSnapshot = await authorRef.get();
      var objUser = authorSnapshot.data() as Map<String, dynamic>;

      recipes.add(Recipe(
          id: doc.id,
          imageUrl: doc['imageUrl'],
          name: doc['title'],
          description: doc['description'],
          likesCount: doc['likesCount'],
          ingredients: List<String>.from(doc['ingredients']),
          instructions: List<String>.from(doc['instructions']),
          authorId: objUser['username'],
          commentCount: doc['commentsCount']));
    }));

    setState(() {
      trendingRecipes = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        trendingRecipes.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                physics: NeverScrollableScrollPhysics(),
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
                            recipe.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          recipe.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Diupload oleh ${recipe.authorId}"),
                        SizedBox(height: 8),
                        Text(
                          recipe.description,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${recipe.likesCount} Likes',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetailScreen(recipe: recipe),
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
  final Recipe recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                recipe.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            SizedBox(height: 16),
            Text(
              recipe.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {},
              child: Text(
                recipe.authorId,
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
              ),
            ),
            SizedBox(height: 16),
            Text(
              recipe.description,
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
            ...recipe.ingredients.map<Widget>((ingredient) {
              return Text('- $ingredient');
            }).toList(),
            SizedBox(height: 16),
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...recipe.instructions.map<Widget>((instruction) {
              return Text('- $instruction');
            }).toList(),
          ],
        ),
      ),
    );
  }
}
