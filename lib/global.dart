import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

checkLogin() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  bool? isLogin = sharedPreferences.getBool('login');
  if (isLogin != null && isLogin && FirebaseAuth.instance.currentUser != null) {
    return true;
  }
  // ScaffoldMessenger.of(context)
  return false;
}
