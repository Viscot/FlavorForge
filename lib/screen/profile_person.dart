import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flavorforge/screen/detail_post.dart';
import 'package:flavorforge/screen/favorite_page.dart';
import 'package:flutter/material.dart';

class ProfilePerson extends StatefulWidget {
  final String username;

  ProfilePerson({Key? key, required this.username}) : super(key: key);

  @override
  State<ProfilePerson> createState() => _ProfilePersonState();
}

class _ProfilePersonState extends State<ProfilePerson> {
  bool isFollow = false;
  int followers = 0;
  List<Recipe> favoriteRecipes = [];
  List<Map<String, dynamic>> userPosts = [];

  @override
  void initState() {
    super.initState();
    checkUserFollow();
    fetchFavoriteRecipes();
    fetchUserPosts();
  }

  void checkUserFollow() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);
    DocumentReference userFollowRef =
        FirebaseFirestore.instance.collection('users').doc(widget.username);

    QuerySnapshot followQuerySnapshot = await FirebaseFirestore.instance
        .collection('follows')
        .where('followId', isEqualTo: userFollowRef)
        .where('userId', isEqualTo: userDocRef)
        .get();

    QuerySnapshot count = await FirebaseFirestore.instance
        .collection('follows')
        .where('followId', isEqualTo: userFollowRef)
        .get();

    setState(() {
      followers = count.docs.length;
      isFollow = followQuerySnapshot.docs.isNotEmpty;
    });
  }

  Future<void> fetchFavoriteRecipes() async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.username);

    QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: userRef)
        .get();

    List favoriteRecipeIds =
        favoritesSnapshot.docs.map((doc) => doc['recipeId'].id).toList();

    List<Recipe> recipes = [];

    for (String recipeId in favoriteRecipeIds) {
      DocumentSnapshot recipeDoc = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .get();
      if (recipeDoc.exists) {
        Recipe recipe = await Recipe.fromFirestore(recipeDoc);
        recipes.add(recipe);
      }
    }
    setState(() {
      favoriteRecipes = recipes;
    });
  }

  Future<void> fetchUserPosts() async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.username);

    QuerySnapshot postSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userRef)
        .get();

    List<Map<String, dynamic>> posts = postSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'username': doc['username'],
        'imageUrl': doc['imageUrl'],
        'caption': doc['caption'],
        'tags': doc['tags'],
        'createdAt': doc['createdAt'],
        'likesCount': doc['likesCount'] ?? 0, // Add likesCount
      };
    }).toList();

    setState(() {
      userPosts = posts;
    });
  }

  Future<void> handleLikePost(String postId, int currentLikes) async {
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('posts').doc(postId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      int newLikes =
          (postSnapshot.data() as Map<String, dynamic>)['likesCount'] + 1;
      transaction.update(postRef, {'likesCount': newLikes});
    });

    setState(() {
      userPosts = userPosts.map((post) {
        if (post['id'] == postId) {
          return {...post, 'likesCount': currentLikes + 1};
        }
        return post;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.username)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          } else {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            print(userData);
            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                          userData['username'].toString().characters.first +
                              userData['username'].toString().characters.last),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${userData['username']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('${userData['jenis_kelamin']}'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isFollow ? Colors.white : Colors.blue,
                      foregroundColor: isFollow ? Colors.black : Colors.white),
                  onPressed: () {
                    String currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    DocumentReference userDocRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserId);
                    DocumentReference userFollowRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.username);

                    if (isFollow) {
                      FirebaseFirestore.instance
                          .collection('follows')
                          .doc(userDocRef.id + userFollowRef.id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Berhasil Unfollow user')));
                      setState(() {
                        followers -= 1;
                        isFollow = false;
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('follows')
                          .doc(userDocRef.id + userFollowRef.id)
                          .set({
                        "userId": userDocRef,
                        "followId": userFollowRef
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Berhasil Follow user')));
                      setState(() {
                        followers += 1;
                        isFollow = true;
                      });
                    }
                  },
                  child: Text(isFollow ? 'Unfollow' : 'Follow'),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Followers',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(followers.toString()),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Post',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(userPosts.length.toString()), // Post count
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Favorite Recipes',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                favoriteRecipes.isEmpty
                    ? Text(
                        'Tidak ada favorite recipe',
                        textAlign: TextAlign.center,
                      )
                    : SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: favoriteRecipes.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              width: 150,
                              child: Column(
                                children: [
                                  Image.network(
                                    favoriteRecipes[index].imageUrl,
                                    width: 150,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    favoriteRecipes[index].title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(height: 16),
                Text(
                  'Recent Posts',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                userPosts.isEmpty
                    ? Text(
                        'Tidak ada postingan',
                        textAlign: TextAlign.center,
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: userPosts.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    child: Text(userPosts[index]['username']
                                            .toString()
                                            .characters
                                            .first +
                                        userPosts[index]['username']
                                            .toString()
                                            .characters
                                            .last),
                                  ),
                                  title: Text(
                                    userPosts[index]['username'].toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Posted on: ${userPosts[index]['createdAt']}'),
                                ),
                                // Post Image
                                userPosts[index]['imageUrl'] != null
                                    ? Image.network(
                                        userPosts[index]['imageUrl'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 250,
                                      )
                                    : SizedBox.shrink(),
                                // Caption and Tags
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userPosts[index]['caption'],
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Tags: ${userPosts[index]['tags'].join(', ')}',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Likes: ${userPosts[index]['likesCount']}',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                // Actions: Like, Comment, Share (Optional)
                                ButtonBar(
                                  alignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.thumb_up,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        handleLikePost(userPosts[index]['id'],
                                            userPosts[index]['likesCount']);
                                      },
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) => DetailPost(
                                                post: userPosts[index]),
                                          ));
                                        },
                                        child: Text('Lihat Detail'))
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
        },
      ),
    );
  }
}
