import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'login_page.dart'; // Import LoginPage
import 'register_page.dart'; // Import RegisterPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isRegistered = false; // Definisikan variabel isRegistered

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flavor Forge'),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Tambahkan logika navigasi ke halaman login
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DiscoverNewRecipes(),
              SizedBox(height: 32),
              SectionTitle(title: 'Feature Recipe'),
              SizedBox(height: 16),
              FeatureRecipeCard(
                title: 'Special Recipe',
                description: 'This is a special recipe.',
                imageUrl: 'https://via.placeholder.com/300',
              ),
              SizedBox(height: 32),
              SectionTitle(title: 'Popular Recipes'),
              SizedBox(height: 16),
              PopularRecipes(),
              SizedBox(height: 32),
              SectionTitle(title: 'Customer Recipes'),
              SizedBox(height: 16),
              CustomerRecipes(),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}

class DiscoverNewRecipes extends StatefulWidget {
  @override
  _DiscoverNewRecipesState createState() => _DiscoverNewRecipesState();
}

class _DiscoverNewRecipesState extends State<DiscoverNewRecipes> {
  final CarouselController _carouselController = CarouselController();
  int _current = 0;

  final List<Map<String, String>> recipes = [
    {'imageUrl': 'https://akcdn.detik.net.id/visual/2023/06/07/ilustrasi-ayam-serundeng_169.jpeg?w=650'},
    {'imageUrl': 'https://kecipir.com/blog/wp-content/uploads/2023/03/resep-gado-gado.jpg'},
    {'imageUrl': 'https://asset.kompas.com/crops/7tBNI9-TCa-oOq8tQTahf0ua1fg=/0x0:968x645/750x500/data/photo/2021/01/27/6010ce2cc1805.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarouselSlider(
          items: recipes.map((recipe) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      recipe['imageUrl']!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 400,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16/9,
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: recipes.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.blue)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PopularRecipes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RecipeCard(
          imageUrl: 'https://via.placeholder.com/150',
        ),
        RecipeCard(
          imageUrl: 'https://via.placeholder.com/150',
        ),
        RecipeCard(
          imageUrl: 'https://via.placeholder.com/150',
        ),
      ],
    );
  }
}

class CustomerRecipes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RecipeCard(
          imageUrl: 'https://via.placeholder.com/150',
        ),
        RecipeCard(
          imageUrl: 'https://via.placeholder.com/150',
        ),
        RecipeCard(
          imageUrl: 'https://via.placeholder.com/150',
        ),
      ],
    );
  }
}

class RecipeCard extends StatelessWidget {
  final String imageUrl;

  RecipeCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class FeatureRecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  FeatureRecipeCard({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
