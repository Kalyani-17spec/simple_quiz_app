import 'package:flutter/material.dart';
import 'package:flutter_app_fbtp/screens/home_screen.dart';

import 'models/db_connect.dart';
import 'models/question_model.dart';

void main(){

  var db = DBconnect();
  /*
  db.addQuestions(
      Question(id: '20',
          title: 'What is 20 x 100 ?',
          options: {
            '100': false,
            '200': true,
            '300' : false,
            '400': false
        }
      )
  );*/
  db.fetchQuestions();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen() ,
    );
  }
}
