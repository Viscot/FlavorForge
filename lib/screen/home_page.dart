import 'package:flavorforge/global.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // Import LoginPage
import 'package:firebase_auth/firebase_auth.dart';
import '../recipes/featured_recipe_widget.dart';
import '../recipes/customer_reviews_widget.dart';
import '../recipes/trending_recipe_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isRegistered = false; // Definisikan variabel isRegistered
  String? username; // Variabel untuk menyimpan nama pengguna

  @override
  void initState() {
    getUserStatus();
    // TODO: implement initState
    super.initState();
  }

  void getUserStatus() async {
    var isLogin = await checkLogin();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String usernameDump = sharedPreferences.getString('username') ?? 'guest';
    setState(() {
      isRegistered = isLogin;
      username = usernameDump;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flavor Forge'),
        backgroundColor: Colors.deepOrange,
        actions: <Widget>[
          Row(
            children: [
              Text(
                isRegistered ? username ?? "Guest" : "Guest",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              IconButton(
                icon: Icon(isRegistered ? Icons.logout : Icons.person),
                onPressed: () async {
                  if (isRegistered) {
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    sharedPreferences.clear();
                    await FirebaseAuth.instance.signOut();
                    setState(() {
                      isRegistered = false;
                    });
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  }
                },
              ),
            ],
          ),
          SizedBox(width: 16), // Menambahkan jarak ke kanan layar
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
              FeaturedRecipeWidget(),
              SizedBox(height: 32),
              SectionTitle(title: 'Trending Recipes'),
              SizedBox(height: 16),
              TrendingRecipesWidget(),
              SizedBox(height: 32),
              SectionTitle(title: 'Customer Recipes'),
              SizedBox(height: 16),
              CustomerReviewsWidget(),
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
        color: Colors.deepOrange,
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

  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRecipes();
  }

  void fetchRecipes() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .orderBy('likesCount', descending: true)
        .limit(3)
        .get();
    setState(() {
      recipes = querySnapshot.docs.map((doc) {
        return {
          'imageUrl': doc['imageUrl'],
          'title': doc['title'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return recipes.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
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
                          child: Stack(
                            children: [
                              Image.network(
                                recipe['imageUrl']!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  color: Colors.black.withOpacity(0.5),
                                  child: Text(
                                    recipe['title']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: 250,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
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
                      width: 12.0,
                      height: 12.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.deepOrange)
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
