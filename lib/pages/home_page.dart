import 'package:flutter/material.dart';
import 'package:mei_app/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mei_app/models/news_pre.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:developer';
import 'package:html/dom.dart' as dom;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pre_News> _todoList;
  int _pageCount = 1;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();

    _todoList = new List();

    _parseHtmlString('https://mpei.ru/news/Pages/news.aspx');
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _parseHtmlString(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      _pageCount = _pageCount + 1;
      List<Pre_News> loadList;
      loadList = document
          .getElementsByClassName('dfwp-item')
          .map((e) => Pre_News(
                e
                    .getElementsByClassName('newsdate news_with_photo_newsdate')
                    .first
                    .text,
                e
                    .getElementsByClassName(
                        'newstitle news_with_photo_newstitle')
                    .first
                    .text,
                e
                    .getElementsByClassName(
                        'newstitle news_with_photo_newstitle')
                    .first
                    .getElementsByTagName('a')
                    .first
                    .attributes['href'],
                "https://mpei.ru" +
                    e
                        .getElementsByClassName(
                            'item newsitem news_with_photo_newsitem')
                        .first
                        .getElementsByTagName('img')
                        .first
                        .attributes['src'],
              ))
          .toList();
      setState(() {
        _todoList.addAll(loadList);
      });
      return response.toString();
    } else
      throw Exception('Failed');
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
              new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Widget _showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            int _cpageCount = _pageCount - 1;
            if (index >= 14 * _cpageCount) {
              _parseHtmlString("https://mpei.ru/news/Pages/news.aspx?p="+_pageCount.toString());
            }
            String date = _todoList[index].date;
            String title = _todoList[index].title;
            if (title.length > 45) title = title.substring(0, 42) + "...";
            String link = _todoList[index].link;
            String img = _todoList[index].img;
            List<String> findId = link.split("=");
            String id = findId.last;
            return new GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/news/' + id + "/" + title);
                },
                child: new Padding(
                    padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 0.0),
                    child: new Container(
                      height: 96,
                      child: new Card(
                        child: new Row(children: <Widget>[
                          new Image.network(
                            img,
                            fit: BoxFit.cover,
                            width: 96.0,
                            height: 96.0,
                          ),
                          Expanded(
                            child: new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          12.0, 6.0, 12.0, 0.0),
                                      child: Text(date,
                                          style: new TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.black87))),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          12.0, 6.0, 12.0, 0.0),
                                      child: Text(title,
                                          style: new TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.indigo))),
                                ]),
                          )
                        ]),
                      ),
                    )));
          });
    } else {
      return Center(
          child: Text(
        "Загрузка списка новостей...",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Новости'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Выход',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _showTodoList());
  }
}
