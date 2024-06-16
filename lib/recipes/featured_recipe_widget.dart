import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flavorforge/recipes/recipe_detail.dart';
import 'package:flavorforge/recipes/recipe_model.dart';

class FeaturedRecipeWidget extends StatefulWidget {
  @override
  _FeaturedRecipeWidgetState createState() => _FeaturedRecipeWidgetState();
}

class _FeaturedRecipeWidgetState extends State<FeaturedRecipeWidget> {
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchTrendingRecipes();
  }

  // Fetch trending recipes from Firestore
  void fetchTrendingRecipes() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('recipes').get();

    List<Recipe> recipeList = [];

    // Use Future.wait to handle asynchronous fetching of author data
    await Future.wait(querySnapshot.docs.map((doc) async {
      DocumentReference authorRef =
          doc['authorId']; // Assume 'authorId' is a DocumentReference
      DocumentSnapshot authorSnapshot = await authorRef.get();
      var objUser = authorSnapshot.data() as Map<String, dynamic>;

      recipeList.add(Recipe(
        id: doc.id,
        imageUrl: doc['imageUrl'],
        name: doc['title'],
        description: doc['description'],
        likesCount: doc['likesCount'],
        ingredients: List<String>.from(doc['ingredients']),
        instructions: List<String>.from(doc['instructions']),
        authorId: objUser['username'],
        commentCount: doc['commentsCount'],
      ));
    }));

    setState(() {
      recipes = recipeList;
    });
  }

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
                MaterialPageRoute(
                    builder: (context) =>
                        RecipeDetailScreen(recipe: recipes[index])),
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
      width: 180,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 115,
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
                children: [],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow
                          .ellipsis, // Add ellipsis if the text is too long
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                      child: Text('Recipe Detail'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
