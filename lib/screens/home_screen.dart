

import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/db_connect.dart';
import '../models/question_model.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/question_widget.dart';
import '../widgets/result_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var db = DBconnect();
  late Future _questions;

  Future<List<Question>> getData()async{
    return db.fetchQuestions();
  }

  @override
  void initState(){
    _questions = getData();
    super.initState();
  }
  /*List<Question> _questions = [
    Question(
      id: '10',
      title: 'What is 2+2 ?',
      options: {'5': false, '30' : false, '4': true, '10':false},
    ),
    Question(
      id: '11',
      title: 'What is 2+20 ?',
      options: {'5': false, '22' : true, '4': false, '10':false},
    )
  ];*/

  int index = 0;
  int score = 0;
  bool isPressed = false;
  bool isAlreadySelected = false;

  void nextQuestion(int questionLength) {
    if (index == questionLength - 1) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Result_box(
            result: score,
            questionLength: questionLength,
            onPressed: startOver,
          ));
    }
    else {
      if (isPressed) {
        setState(() {
          index++;
          isPressed = false;
          isAlreadySelected = false;
        });
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Please select any option'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(vertical: 20.0),
            ));
      }
    }
  }

  void chaneColor(){
    setState(() {
      isPressed = true;
    });
  }
  void checkAnswerAndUpdate(bool value){
    if(isAlreadySelected){
      return;
    }
    else{
      if(value == true){
        score++;
      }
      setState(() {
        isPressed = true;
        isAlreadySelected = true;
      });
    }
  }

  void startOver(){
    setState(() {
      index = 0;
      score = 0;
      isPressed = false;
      isAlreadySelected = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _questions as Future<List<Question>>,
        builder: (ctx, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError){
              return Center(child: Text('${snapshot.error}'),);
            }
            else if(snapshot.hasData){
              var extractedData = snapshot.data as List<Question>;
              return Scaffold(
                backgroundColor: background,
                appBar: AppBar(
                  title: const Text('Quiz App'),
                  backgroundColor: background,
                  shadowColor: Colors.transparent,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Text(
                        'Score: $score',
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
                body: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      QuestionWidget(
                          indexAction: index,
                          question: extractedData[index].title,
                          totalQuestions: extractedData.length
                      ),
                      const Divider(color: neutral),
                      const SizedBox(height: 25.0),
                      for(int i = 0;i < extractedData[index].options.length;i++)
                        GestureDetector(
                          onTap: () => checkAnswerAndUpdate(extractedData[index].options.values.toList()[i]),
                          child: OptionCard(option: extractedData[index].options.keys.toList()[i],
                            color: isPressed
                                ? extractedData[index].options.values.toList()[i] == true
                                ? correct
                                : incorrect
                                :neutral,
                            //onTap: chaneColor,
                          ),
                        ),
                    ],
                  ),
                ),
                floatingActionButton: GestureDetector(
                  onTap: () => nextQuestion(extractedData.length),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: NextButton(
                    ),
                  ),
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              );
            }
          }
          else{
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return const Center(
            child: Text('No Data'),
          );
        },

    );
  }
}
