import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flavorforge/global.dart';
import 'package:flavorforge/main.dart';
import 'package:flavorforge/recipes/recipe_model.dart';
import 'package:flavorforge/recipes/trending_recipe_widget.dart';
import 'package:flavorforge/screen/home_page.dart';
import 'package:flavorforge/screen/profile_person.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool updateSc = false;
  bool isLiked = false;
  DocumentReference? likeRef;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    checkLikeStatus();
  }

  void checkLikeStatus() async {
    if (FirebaseAuth.instance.currentUser!.uid != null) {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc();
      DocumentReference recipeRef = FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipe.id);

      likeRef = await checkLike(userRef, recipeRef);
      setState(() {
        if (likeRef == null) {
          isLiked = false;
        } else {
          isLiked = true;
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Harap login terlebih dahulu')));
    }
  }

  Future<DocumentReference?> checkLike(
      DocumentReference userRef, DocumentReference recipeRef) async {
    CollectionReference likesRef =
        FirebaseFirestore.instance.collection('likes');

    QuerySnapshot querySnapshot = await likesRef
        .where('userId', isEqualTo: userRef)
        .where('recipeId', isEqualTo: recipeRef)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print("masuk sono");
      return querySnapshot.docs.first.reference;
    } else {
      print("masuk sini");
      return null;
    }
  }

  Future<void> likeRecipe(
      DocumentReference userRef, DocumentReference recipeRef) async {
    var isLogin = await checkLogin();
    if (isLogin) {
      CollectionReference likesRef =
          FirebaseFirestore.instance.collection('likes');
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Add a new like document
      batch.set(likesRef.doc(), {
        'userId': userRef,
        'recipeId': recipeRef,
        'likedAt': Timestamp.now(),
      });

      // Increment the likesCount in the recipe document
      batch.update(recipeRef, {
        'likesCount': FieldValue.increment(1),
      });

      await batch.commit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('silahkan login terlebih dahulu')));
    }
  }

  Future<void> unlikeRecipe(
      DocumentReference likeRef, DocumentReference recipeRef) async {
    var isLogin = await checkLogin();
    if (isLogin) {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Delete the like document
      batch.delete(likeRef);

      // Decrement the likesCount in the recipe document
      batch.update(recipeRef, {
        'likesCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('silahkan login terlebih dahulu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomSheet: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: InputWidget(
            recipeId: widget.recipe.id,
            callbackAction: () {
              setState(() {
                updateSc = !updateSc;
              });
            },
          ),
        ),
        appBar: AppBar(
          title: Text(widget.recipe.name),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => MainPage(),
                    ),
                    (route) => false);
              },
              icon: Icon(
                Icons.arrow_back_ios,
              )),
        ),
        body: ListView(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.recipe.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () async {
                      var isLogin = await checkLogin();
                      if (isLogin) {
                        if (isLiked) {
                          DocumentReference recipeRef = FirebaseFirestore
                              .instance
                              .collection('recipes')
                              .doc(widget.recipe.id);
                          await unlikeRecipe(likeRef!, recipeRef);
                          setState(() {
                            isLiked = false;
                          });
                        } else {
                          DocumentReference userRef = FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid);
                          DocumentReference recipeRef = FirebaseFirestore
                              .instance
                              .collection('recipes')
                              .doc(widget.recipe.id);

                          await likeRecipe(userRef, recipeRef);
                          setState(() {
                            isLiked = true;
                            // updateSc != updateSc;
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Harap login terlebih dahulu')));
                      }
                    },
                    icon: Icon(
                      Icons.thumb_up,
                      color: isLiked ? Colors.blue : Colors.white,
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.recipe.description,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () async {
                  QuerySnapshot snapshotUser = await FirebaseFirestore.instance
                      .collection('users')
                      .where('username', isEqualTo: widget.recipe.authorId)
                      .get();

                  if (snapshotUser.docs.isNotEmpty) {
                    var isLogin = await checkLogin();
                    if (isLogin) {
                      var userDoc = snapshotUser.docs.first;
                      var userId = userDoc.id;

                      if (userId == FirebaseAuth.instance.currentUser!.uid) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Kamu tidak bisa mengunjungi akunmu sendiri')));
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfilePerson(username: userId),
                        ));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Ops harap login terlebih dahulu')));
                    }
                  } else {
                    // Handle the case where no user is found
                    print('User not found');
                  }
                },
                child: Text(
                  "Di upload oleh ${widget.recipe.authorId}",
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.blue),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailPage(recipe: widget.recipe)),
                    );
                  },
                  child: Text('Try Recipe')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  var isLogin = await checkLogin();
                  if (isLogin) {
                    DocumentReference userref = FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid);
                    DocumentReference recipeRef = FirebaseFirestore.instance
                        .collection('recipes')
                        .doc(widget.recipe.id);
                    DocumentSnapshot referenceFavrite = await FirebaseFirestore
                        .instance
                        .collection("favorites")
                        .doc(userref.id + recipeRef.id)
                        .get();
                    if (referenceFavrite.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('ops kamu sudah menambahkan ke favorite')));
                    } else {
                      FirebaseFirestore.instance
                          .collection('favorites')
                          .doc(userref.id + recipeRef.id)
                          .set({"recipeId": recipeRef, "userId": userref});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Berhasil menambahkan kedalam favorite')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('silahkan login terlebih dahulu')));
                  }
                },
                child: Text('Add To Favorite'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                "User Review",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: CommentSection(recipeId: widget.recipe.id),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final String recipeId;

  CommentSection({required this.recipeId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  bool refresh = false;

  Future<List<Comment>> fetchComments() async {
    DocumentReference recipeRef =
        FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('comments')
        .where('recipeId', isEqualTo: recipeRef)
        .get();

    List<Comment> comments = await Future.wait(snapshot.docs.map((doc) async {
      Timestamp createdAt = doc['createdAt'];
      List<Reply> replies = [];
      DocumentReference authorId = doc['userId'];
      DocumentSnapshot userDocs = await authorId.get();
      var userData = userDocs.data() as Map<String, dynamic>;

      if (doc['replies'] != null) {
        replies = await Future.wait(
            List.from(doc['replies']).map<Future<Reply>>((replyData) async {
          Timestamp replyCreatedAt = replyData['createdAt'];
          DocumentReference userRef = replyData['userId'];
          DocumentSnapshot userSnapshot = await userRef.get();
          var username = userSnapshot.data() as Map<String, dynamic>;
          return Reply(
            id: replyData['id'] ?? '',
            comment: replyData['comment'],
            createdAt: replyCreatedAt.toDate(),
            userId: username['username'],
          );
        }).toList());
      }

      return Comment(
          id: doc.id,
          comment: doc['comment'],
          createdAt: createdAt.toDate(),
          recipeId: recipeRef.id,
          replies: replies,
          authorId: userData['username']);
    }).toList());

    return comments;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comment>>(
      future: fetchComments(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<Comment> comments = snapshot.data ?? [];

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return CommentWidget(
              comment: comment,
              recipeId: widget.recipeId,
              callbackAction: () {
                setState(() {
                  refresh = !refresh;
                });
              },
            );
          },
        );
      },
    );
  }
}

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final VoidCallback callbackAction;
  final String recipeId;

  CommentWidget({
    required this.comment,
    required this.callbackAction,
    required this.recipeId,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool visible = false;

  void toggleRepliesVisibility() {
    setState(() {
      visible = !visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.comment.comment,
                    style: TextStyle(fontSize: 16),
                  ),
                  InkWell(
                    child: Text(
                      "Diupload oleh ${widget.comment.authorId}",
                      style:
                          TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: toggleRepliesVisibility,
                child: Icon(
                  visible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 32,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                "${widget.comment.createdAt.year}-${widget.comment.createdAt.month}-${widget.comment.createdAt.day} ${widget.comment.createdAt.hour}:${widget.comment.createdAt.minute}",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (visible)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replies:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.comment.replies.length,
                  itemBuilder: (context, index) {
                    final Random random = Random();
                    Color backgroundColor = Color.fromRGBO(
                      random.nextInt(256),
                      random.nextInt(256),
                      random.nextInt(256),
                      1,
                    );
                    final reply = widget.comment.replies[index];
                    return ReplyWidget(
                      reply: reply,
                      color: backgroundColor,
                    );
                  },
                ),
                ReplyInputWidget(
                  commentId: widget.comment.id,
                  callbackAction: widget.callbackAction,
                ),
              ],
            ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class ReplyWidget extends StatelessWidget {
  final Reply reply;
  final Color color;

  ReplyWidget({required this.reply, required this.color});

  @override
  Widget build(BuildContext context) {
    String initial = reply.userId.substring(0, 1).toUpperCase();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(reply.userId),
                ],
              ),
              Text(
                reply.comment,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey),
              SizedBox(width: 2),
              Text(
                "${reply.createdAt.year}-${reply.createdAt.month}-${reply.createdAt.day} ${reply.createdAt.hour}:${reply.createdAt.minute}",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InputWidget extends StatefulWidget {
  final String recipeId;
  final VoidCallback callbackAction;

  InputWidget({required this.recipeId, required this.callbackAction});

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Add comment',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              String replyText = _replyController.text.trim();
              if (replyText.isNotEmpty) {
                var isLogin = await checkLogin();
                if (isLogin) {
                  DocumentReference userRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid);

                  DocumentReference recipeRef = FirebaseFirestore.instance
                      .collection('recipes')
                      .doc(widget.recipeId);

                  Future<void> addComment(
                      String commentText,
                      DocumentReference recipeRef,
                      DocumentReference userRef) async {
                    try {
                      var isLogin = await checkLogin();
                      if (isLogin) {
                        await FirebaseFirestore.instance
                            .collection('comments')
                            .add({
                          'comment': commentText,
                          'recipeId': recipeRef,
                          'userId': userRef,
                          'replies': [],
                          'createdAt': Timestamp.now()
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Ops silahkan login terlebih dahulu')));
                      }
                    } catch (e) {
                      print('Error adding comment: $e');
                    }
                  }

                  await addComment(replyText, recipeRef, userRef);

                  _replyController.clear();
                  widget.callbackAction();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Ops harap login terlebih dahulu')));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
}

class ReplyInputWidget extends StatefulWidget {
  final String commentId;
  final VoidCallback callbackAction;

  ReplyInputWidget({required this.commentId, required this.callbackAction});

  @override
  _ReplyInputWidgetState createState() => _ReplyInputWidgetState();
}

class _ReplyInputWidgetState extends State<ReplyInputWidget> {
  TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Reply to comment...',
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              String replyText = _replyController.text.trim();
              if (replyText.isNotEmpty) {
                var isLogin = await checkLogin();
                if (isLogin) {
                  DocumentReference userRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid);

                  await FirebaseFirestore.instance
                      .collection('comments')
                      .doc(widget.commentId)
                      .update({
                    'replies': FieldValue.arrayUnion([
                      {
                        'comment': replyText,
                        'createdAt': Timestamp.now(),
                        'userId': userRef,
                      }
                    ])
                  });
                  _replyController.clear();
                  widget.callbackAction();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('ops silahkan login terlebih dahulu')));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
}

class Comment {
  final String id;
  final String comment;
  final DateTime createdAt;
  final String recipeId;
  final List<Reply> replies;

  String authorId;

  Comment(
      {required this.id,
      required this.comment,
      required this.createdAt,
      required this.recipeId,
      required this.replies,
      required this.authorId});
}

class Reply {
  final String id;
  final String comment;
  final DateTime createdAt;
  final String userId;

  Reply({
    required this.id,
    required this.comment,
    required this.createdAt,
    required this.userId,
  });
}
