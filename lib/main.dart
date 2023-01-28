import 'package:flutter/material.dart';
import 'package:librarymangment/pages/home.dart';
import 'package:librarymangment/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp( _MyApp());
}


class _MyApp extends StatefulWidget {


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  _checkIfLoggedIn() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var sid = sharedPreferences.getString("sid");
    if (sid != null) {
      // Use the sid to authenticate the user
      // And set _isLoggedIn to true
      _isLoggedIn = true;
    }
    setState(() {
      _isLoggedIn = _isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const Home(),
      },
      home: _isLoggedIn ? const Home() : const LoginPage(),
    );
  }
}
