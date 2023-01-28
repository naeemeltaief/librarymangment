import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:librarymangment/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<http.Response> login(String username, String password) async {
  final response = await http.post(
    Uri.parse(
        'http://library.test:8000/api/method/library_management.api.login'),
    body: {'usr': username, 'pwd': password},
  );
  return response;
}

class _LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    final response =
        await login(_usernameController.text, _passwordController.text);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey("message") && data["message"]["success_key"] == 1) {
        var sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString(
            "api_key", data["message"]["api_key"]);
        await sharedPreferences.setString(
            "api_secret", data["message"]["api_secret"]);
        await sharedPreferences.setString("sid", data["message"]["sid"]);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } else {
        // Show an error message
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data["message"]["message"])));
      }
    } else {
      // Show an error message
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }
}
