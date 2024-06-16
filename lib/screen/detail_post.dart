import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPost extends StatefulWidget {
  DetailPost({Key? key, required this.post});

  final Map<String, dynamic> post;

  @override
  State<DetailPost> createState() => _DetailPostState();
}

class _DetailPostState extends State<DetailPost> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post['username']),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for post content
          Container(
            height: 200,
            alignment: Alignment.center,
            child: Image.network(
              widget.post['imageUrl'],
              fit: BoxFit.cover,
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.post['caption'],
              textAlign: TextAlign.left,
            ),
          ),
          // Placeholder for comments
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('commentsPost')
                          .where('postId',
                              isEqualTo: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(widget.post['id']))
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final comments = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text((comment['username']
                                            .toString()
                                            .characters
                                            .first +
                                        comment['username']
                                            .toString()
                                            .characters
                                            .last)
                                    .toString()),
                              ),
                              title: Text(comment['username']),
                              subtitle: Text(comment['comment']),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    // Handle adding comment
                    // Handle adding comment
                    DocumentReference reference = FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.post['id']);
                    DocumentReference userRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid);

                    DocumentSnapshot userSnap = await userRef.get();

                    String newComment = _controller.text;
                    if (newComment.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('commentsPost')
                          .add({
                        'postId': reference,
                        'userId': userRef,
                        'username': userSnap['username'],
                        'comment': newComment,
                        'timestamp': DateTime
                            .now(), // Tambahkan timestamp jika diperlukan
                      }).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Berhasil add comments')));
                        print('Comment added successfully');
                      }).catchError((error) {
                        // Gagal menambahkan komentar
                        print('Failed to add comment: $error');
                      });
                    }
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
