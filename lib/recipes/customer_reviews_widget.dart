import 'package:flutter/material.dart';

class CustomerReviewsWidget extends StatefulWidget {
  @override
  _CustomerReviewsWidgetState createState() => _CustomerReviewsWidgetState();
}

class _CustomerReviewsWidgetState extends State<CustomerReviewsWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Comment> comments = []; // Daftar komentar

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    // Inisialisasi komentar
    comments = [
      Comment(
        userName: 'John Doe',
        rating: 4,
        comment: 'Great Carbonara, highly recommended!',
        imageUrl: 'https://static01.nyt.com/images/2021/02/14/dining/carbonara-horizontal/carbonara-horizontal-square640-v2.jpg',
        foodName: 'Carbonara',
      ),
      Comment(
        userName: 'Jane Smith',
        rating: 5,
        comment: 'Excellent Burger, will buy again!',
        imageUrl: 'https://via.placeholder.com/150',
        foodName: 'Burger',
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: _animation.value,
            child: Container(
              height: 300, // Ubah tinggi kontainer
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Reviews',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true, // Tambahkan properti shrinkWrap: true di sini
                        scrollDirection: Axis.horizontal,
                        itemCount: comments.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ReviewItem(
                            comment: comments[index],
                            onReplyPressed: () {
                              print('Reply to ${comments[index].userName}\'s comment');
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Struktur data untuk komentar
class Comment {
  final String userName;
  final int rating;
  final String comment;
  final String imageUrl;
  final String foodName;

  Comment({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.imageUrl,
    required this.foodName,
  });
}

class ReviewItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback onReplyPressed;

  const ReviewItem({
    required this.comment,
    required this.onReplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350, // Ubah lebar kontainer
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${comment.userName}\'s Review of ${comment.foodName}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 4),
                      Text(
                        comment.rating.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: onReplyPressed,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.mode_comment, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (comment.imageUrl.isNotEmpty)
            Image.network(
              comment.imageUrl,
              width: 300, // Ubah lebar gambar
              height: 150, // Ubah tinggi gambar
              fit: BoxFit.cover,
            ),
          SizedBox(height: 8),
          Text(
            comment.comment,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}