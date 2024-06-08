import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _signInWithUsernameAndPassword(context);
                },
                child: Text('Login'),
              ),
              SizedBox(height: 8.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('Belum punya akun? Daftar di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithUsernameAndPassword(BuildContext context) async {
  try {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    // Langsung menggunakan username sebagai bagian dari email
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: '$username', // Menggunakan username langsung sebagai email
      password: password,
    );

    // Jika autentikasi berhasil, lanjutkan ke halaman berikutnya
    final User? user = userCredential.user;
    if (user != null) {
      // Navigasi ke halaman berikutnya
      // Misalnya, Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextPage()));
    }
  } catch (e) {
    // Tangani kesalahan autentikasi di sini, misalnya tampilkan pesan kesalahan
    print('Error signing in: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error signing in: $e'),
    ));
  }
}
}