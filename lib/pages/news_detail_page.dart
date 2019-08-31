import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/flutter_html.dart';

class NewsDetails extends StatefulWidget {
  NewsDetails({this.link, this.title});

  final String title;
  final String link;

  @override
  State<StatefulWidget> createState() => new _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  String data = "загрузка...";

  // static String html = '<h1>This is heading 1</h1> <h2>This is heading 2</h2><h3>This is heading 3</h3><h4>This is heading 4</h4><h5>This is heading 5</h5><h6>This is heading 6</h6><img alt="Test Image" src="https://i.ytimg.com/vi/RHLknisJ-Sg/maxresdefault.jpg" /><p>This paragraph contains a lot of lines in the source code, but the browser ignores it.</p>';
  @override
  void initState() {
    super.initState();
    _parseHtmlString(
        "https://mpei.ru/news/Lists/PortalNews/NewsDispForm.aspx?ID=" +
            widget.link);
  }

  @override
  Widget build(BuildContext context) {
    final Set<Factory> gestureRecognizers = [
      Factory(() => EagerGestureRecognizer()),
    ].toSet();
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Padding(
          padding: EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 0.0),
          child: new SingleChildScrollView(
            child: new Center(
              child: new Html(data: data),
              //child: new Text(data),
            ),
          ),
        ));
  }

  Future<String> _parseHtmlString(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);

      dom.Element mainElement = document.getElementById('WebPartWPQ3');
      data = mainElement.innerHtml;

      dom.Element elementToCut = document.getElementById('breadcrumb');
      String toCut = elementToCut.innerHtml;

      data = data.replaceFirst(toCut, "").replaceAll("<img src=\"/news/", "<img src=\"https://mpei.ru/news/").replaceAll("alt", "alt1");

      List<dom.Element> toReplace = mainElement.getElementsByTagName('a');
      for (int i = 0; i < toReplace.length; i++) {
        data = data.replaceAll(toReplace[i].outerHtml, toReplace[i].text);
      }

      setState(() {
          data =data;
      });
      return response.toString();
    } else
      throw Exception('Failed');
  }
}
