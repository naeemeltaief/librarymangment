import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Article> fetchArticle() async {
  final response = await http.get(
    Uri.parse(
        'http://library.test:8000/api/method/library_management.library_management.doctype.article.api.get_article_details'),
    headers: {
      HttpHeaders.authorizationHeader: 'Token',
      HttpHeaders.hostHeader: 'library.test:8000',
      HttpHeaders.acceptHeader: 'accept: application/json',
    },
  );
  final responseJson = jsonDecode(response.body);
  return Article.fromJson(responseJson);
}

Future<Article> updateStatus(String status) async {
  final response = await http.put(
      Uri.parse(
          'http://library.test:8000/api/method/library_management.library_management.doctype.article.api.get_article_details'),
      headers: {
        HttpHeaders.authorizationHeader: 'Token',
        HttpHeaders.hostHeader: 'library.test:8000',
        HttpHeaders.acceptHeader: 'accept: application/json',
      },
      body: jsonEncode(<String, String>{
        'status': status,
      })
      );
  final responseJson = jsonDecode(response.body);
  return Article.fromJson(responseJson);
}
// To parse this JSON data, do
//
//     final article = articleFromJson(jsonString);

Article articleFromJson(String str) => Article.fromJson(json.decode(str));

String articleToJson(Article data) => json.encode(data.toJson());

class Article {
  Article({
    required this.message,
  });

  List<Message> message;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        message:
            List<Message>.from(json["message"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": List<dynamic>.from(message.map((x) => x.toJson())),
      };
}

class Message {
  Message({
    required this.image,
    required this.name,
    required this.author,
    required this.publisher,
    required this.status,
  });

  String image;
  String name;
  String author;
  String publisher;
  String status;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        image: json["image"],
        name: json["name"],
        author: json["author"],
        publisher: json["publisher"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "name": name,
        "author": author,
        "publisher": publisher,
        "status": status,
      };
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Article> futureArticle;

  @override
  void initState() {
    super.initState();
    futureArticle = fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fetch Data Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Fetch Data Example'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                futureArticle = fetchArticle();
              });
            },
            child: const Icon(Icons.refresh),
          ),
          body: Center(
            child: FutureBuilder<Article>(
              future: futureArticle,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.message.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: SizedBox(
                          height: 80,
                          width: 50,
                          child: Image.network(
                            'http://library.test:8000${snapshot.data!.message[index].image}',
                          ),
                        ),
                        title: Text(snapshot.data!.message[index].name),
                        subtitle: Text(snapshot.data!.message[index].author),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                snapshot.data!.message[index].status
                                        .contains('Available')
                                    ? Colors.green
                                    : Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              if (snapshot.data!.message[index].status
                                  .contains('Available')) {
                                snapshot.data!.message[index].status =
                                    'Issued';
                              } else {
                                snapshot.data!.message[index].status =
                                    'Available';
                              }
                            updateStatus(snapshot.data!.message[index].status);
                            });
                          },
                          child: Text(
                            snapshot.data!.message[index].status,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ));
  }
}
