import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int likesCount;
  final int commentCount;
  final String authorId;

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.likesCount,
    required this.commentCount,
    required this.authorId,
  });

  // Factory method to create Recipe from Firestore document
  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    var author = data['authorId'] as DocumentReference;
    var user = author.get();

    return Recipe(
      id: doc.id,
      name: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      authorId: "",
    );
  }
}
