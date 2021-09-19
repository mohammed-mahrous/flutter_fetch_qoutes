import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class MyhomePage extends StatefulWidget {
  MyhomePage({Key? key}) : super(key: key);

  @override
  _MyhomePageState createState() => _MyhomePageState();
}

class _MyhomePageState extends State<MyhomePage> {
  late Future<Qoutes> qoutes;
  late String? tag;
  late String? author;
  late String? count;

  @override
  void initState() {
    super.initState();
    qoutes = getQoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: Text('HomePage'),
      ),
      body: FutureBuilder(
        future: qoutes,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            if (snapshot.hasData) {
              List qoutes = snapshot.data!.qoutes;
              return getlistview(qoutes);
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        backgroundColor: Colors.deepPurple[700],
        onPressed: () {
          setState(() {
            qoutes = getQoute();
          });
        },
      ),
    );
  }

  Column futureWidget(List<dynamic> qoutes) {
    return Column(
        children: qoutes.map((qoute) {
      String author = qoute['author'];
      String text = qoute['text'];
      String tag = qoute['tag'];
      return Container(
        margin: EdgeInsets.all(3),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                author.trim(),
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.white24),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                text.trim(),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.indigo[800],
                child: Text(
                  tag.trim(),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList());
  }
}

ListView getlistview(List list) {
  return ListView.separated(
    addAutomaticKeepAlives: false,
    addRepaintBoundaries: true,
    scrollDirection: Axis.vertical,
    itemCount: list.length,
    separatorBuilder: (BuildContext context, int index) {
      return Divider(
        height: 10,
        thickness: 3,
        indent: 5,
        endIndent: 5,
      );
    },
    itemBuilder: (BuildContext context, int index) {
      String author = list[index]['author'];
      String text = list[index]['text'];
      String tag = list[index]['tag'];
      return Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                author.trim(),
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '\"${text.trim()}\"',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white60,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    'tags:',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.deepPurple[500],
                    child: Text(
                      tag.trim(),
                      textAlign: TextAlign.start,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<Qoutes> getQoute({tag, count, type}) async {
  tag = type != null ? tag : '';
  type = type != null ? type : '';
  count = count != null ? count : '20';
  String url = 'https://goquotes-api.herokuapp.com/api/v1/random?count=$count';
  if (type != '' && tag != '') {
    url =
        'https://goquotes-api.herokuapp.com/api/v1/random/$count?type=$type&val=$tag';
  }

  final response = await http.get(Uri.parse(url));
  debugPrint((response.statusCode).toString());
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var data = jsonDecode(response.body);
    debugPrint((data).toString());
    return Qoutes.fromJson(data);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
}

class Qoutes {
  final List qoutes;
  final int count;

  Qoutes({required this.qoutes, required this.count});

  factory Qoutes.fromJson(Map<String, dynamic> json) {
    return Qoutes(
      qoutes: json['quotes'],
      count: json['count'],
    );
  }
}
