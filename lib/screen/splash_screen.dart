import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'home_page.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 243, 100, 33), Color.fromARGB(255, 210, 47, 18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.network(
                'https://media.discordapp.net/attachments/1010915481990991943/1251892489535881286/logoff-removebg-preview.png?ex=66703b3c&is=666ee9bc&hm=d9885f5cd3d9924e9e25e8aa2df970bdb94960dfd34841c1233d2adf5b841ccf&=&format=webp&quality=lossless&width=546&height=437', // Ganti URL ini dengan URL gambar yang diinginkan
                width: 200,
                height: 200,
              ),
              SizedBox(height: 20),
              Text(
                'FLAVOR FORGE',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 20),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Loading...',
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: Duration(milliseconds: 200),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}
