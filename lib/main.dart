import 'package:flutter/material.dart';
import 'package:mei_app/services/authentication.dart';
import 'package:mei_app/pages/root_page.dart';
import 'package:mei_app/pages/news_detail_page.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primarySwatch: CompanyColors.black,
          textTheme: new TextTheme(
            body1: new TextStyle(color: Colors.black87),
            body2: new TextStyle(color: Colors.black87),
            button: new TextStyle(color: Colors.black87),
            caption: new TextStyle(color: Colors.black87),
            display1: new TextStyle(color: Colors.black87),
            display2: new TextStyle(color: Colors.black87),
            display3: new TextStyle(color: Colors.black87),
            display4: new TextStyle(color: Colors.black87),
            headline: new TextStyle(color: Colors.black87),
            subhead: new TextStyle(color: Colors.orange),
            // <-- that's the one
            title: new TextStyle(color: Colors.black87),
          ),
          inputDecorationTheme: new InputDecorationTheme(
            fillColor: Colors.orange,
          )),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => RootPage(auth: new Auth()),
        '/news': (BuildContext context) => NewsDetails()
      },
      onGenerateRoute: (routeSettings) {
        var path = routeSettings.name.split('/');

        if (path[1] == "news") {
          return new MaterialPageRoute(builder: (context) => NewsDetails(link: path[2], title: path[3]),
          settings:  routeSettings);
        }

        return null;
      },
    );
  }
}

class CompanyColors {
  CompanyColors._(); // this basically makes it so you can instantiate this class

  static const _blackPrimaryValue = 0xFF183e6d;

  static const MaterialColor black = const MaterialColor(
    _blackPrimaryValue,
    const <int, Color>{
      50: const Color(_blackPrimaryValue),
      100: const Color(_blackPrimaryValue),
      200: const Color(_blackPrimaryValue),
      300: const Color(_blackPrimaryValue),
      400: const Color(_blackPrimaryValue),
      500: const Color(_blackPrimaryValue),
      600: const Color(_blackPrimaryValue),
      700: const Color(_blackPrimaryValue),
      800: const Color(_blackPrimaryValue),
      900: const Color(_blackPrimaryValue),
    },
  );
}
