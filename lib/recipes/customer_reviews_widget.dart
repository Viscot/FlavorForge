import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flavorforge/global.dart';
import 'package:flavorforge/screen/profile_person.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerReviewsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('comments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        List<Comment> comments = snapshot.data!.docs.map((doc) {
          Timestamp createdAt = doc['createdAt'];
          DocumentReference recipeRef = doc['recipeId'];
          DocumentReference userRef = doc['userId'];

          return Comment(
            id: doc.id,
            comment: doc['comment'],
            createdAt: createdAt.toDate(),
            recipeRef: recipeRef,
            userRef: userRef,
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return FutureBuilder(
                  future: Future.wait([
                    comment.recipeRef.get(),
                    comment.userRef.get(),
                  ]),
                  builder: (context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    Recipe recipe = Recipe(
                      id: snapshot.data![0].id,
                      title: snapshot.data![0]
                          ['title'], // Adjust field as per your Recipe model
                    );

                    User user = User(
                      id: snapshot.data![1].id,
                      username: snapshot.data![1]
                          ['username'], // Adjust field as per your User model
                    );

                    // Generate random background color
                    final Random random = Random();
                    Color backgroundColor = Color.fromRGBO(
                      random.nextInt(256),
                      random.nextInt(256),
                      random.nextInt(256),
                      1,
                    );

                    // Get initial from username
                    String initial =
                        user.username.substring(0, 1).toUpperCase() +
                            user.username.characters.last.toUpperCase();

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              var isLogin = await checkLogin();
                              if (isLogin) {
                                if (FirebaseAuth.instance.currentUser!.uid ==
                                    user.id) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Ops kamu tidak bisa mengunjungi akun kamu sendiri')));
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePerson(username: user.id),
                                  ));
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Ops harap login terlebih dahulu')));
                              }
                            },
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: backgroundColor,
                              child: Text(
                                initial,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    var isLogin = await checkLogin();
                                    if (isLogin) {
                                      if (FirebaseAuth
                                              .instance.currentUser!.uid ==
                                          user.id) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Ops kamu tidak bisa mengunjungi akun kamu sendiri')));
                                      } else {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) =>
                                              ProfilePerson(username: user.id),
                                        ));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Ops harap login terlebih dahulu')));
                                    }
                                  },
                                  child: Text(
                                    user.username,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  comment.comment,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "${comment.createdAt.year}-${comment.createdAt.month}-${comment.createdAt.day} ${comment.createdAt.hour}:${comment.createdAt.minute}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Recipe: ${recipe.title}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class Comment {
  final String id;
  final String comment;
  final DateTime createdAt;
  final DocumentReference recipeRef;
  final DocumentReference userRef;

  Comment({
    required this.id,
    required this.comment,
    required this.createdAt,
    required this.recipeRef,
    required this.userRef,
  });
}

class Recipe {
  final String id;
  final String title;

  Recipe({
    required this.id,
    required this.title,
  });
}

class User {
  final String id;
  final String username;

  User({
    required this.id,
    required this.username,
  });
}
