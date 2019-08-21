import 'package:firebase_database/firebase_database.dart';

class Pre_News {

  String date;
  String title;
  String link;
  String img;

  Pre_News(this.date, this.title, this.link, this.img);



  toJson() {
    return {
      "date": date,
      "title": title,
      "link": link,
      "img": img,
    };
  }
}