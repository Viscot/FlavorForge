import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _logoSize = 100.0; // Initial size of the logo
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animateSplash();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  void _animateSplash() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
      _controller.forward();
      // Enlarge the logo to the final size
      setState(() {
        _logoSize = 150.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(seconds: 2),
                curve: Curves.easeInOut,
                width: _logoSize,
                height: _logoSize,
                child: Image.network(
                  'https://media.discordapp.net/attachments/1010915481990991943/1252102850981662750/LOGO.png?ex=6670ff26&is=666fada6&hm=79066ca37aa2f401ca21d497b0149fd21ade84ac812dc562fbfe941a928df160&=&format=webp&quality=lossless&width=437&height=437', // Replace with your logo URL
                ),
              ),
              SizedBox(height: 20),
              FadeTransition(
                opacity: _controller,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'WELCOME TO FLAVOR FORGE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(seconds: 2),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
