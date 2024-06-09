import 'package:flutter/material.dart';

class CustomerReviewsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> customerReviews = [
    {
      'imageUrl': 'https://i.pinimg.com/474x/b7/e3/eb/b7e3ebe45c884912c3858ff3041ec504.jpg',
      'author': 'Maryanto',
      'comment': 'Aku sangat menyukai kue sus nya, itu sangat enak sekali!',
      'likes': 100,
    },
    {
      'imageUrl': 'https://i.pinimg.com/736x/52/a7/07/52a7075e1eae28ee8b32fc4c889078cd.jpg',
      'author': 'Hansen',
      'comment': 'Ternyata mudah ya membuat nasi goreng',
      'likes': 25,
    },
    {
      'imageUrl': 'https://i.pinimg.com/564x/9f/64/a6/9f64a60274ae7e8a583e698d8cc3f5ea.jpg',
      'author': 'Novandry',
      'comment': 'Rasa es krim ini sangat berbagai macam!',
      'likes': 80,
    },
    {
      'imageUrl': 'https://i.pinimg.com/originals/f4/ac/83/f4ac8395ef1a34390055fe7cb43af1ff.jpg',
      'author': 'Witri',
      'comment': 'Terima kasih untuk membuat resep ayam kari itu sangat enak!',
      'likes': 150,
    },
    {
      'imageUrl': 'https://cdn.idntimes.com/content-images/community/2022/09/img-20220912-185225-89c2614f83929c7e9b0faaddbd1bc1a5-73772557131951cd9a6bf5119b84d331.jpg',
      'author': 'Iqbal',
      'comment': 'Teruskan dan kembangkan resep nasi goreng Toyib',
      'likes':  70,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          itemCount: customerReviews.length,
          itemBuilder: (context, index) {
            final review = customerReviews[index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(review['imageUrl']),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review['author'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          review['comment'],
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              color: Colors.blue,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${review['likes']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

