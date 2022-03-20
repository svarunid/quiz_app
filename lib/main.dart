import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import 'package:http/http.dart' as http;

import 'model/question.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  Future<List<Question>> fetchQuestions() async {
    List<Question> questions = [];
    String url =
        "https://opentdb.com/api.php?amount=10&category=18&type=multiple";
    http.Response response = await http.get(
      Uri.parse(url),
    );
    List results = jsonDecode(response.body)["results"];
    questions =
        results.getRange(0, 3).map((element) => Question.fromJson(element)).toList();
    return questions;
  }

  @override
  Widget build(BuildContext context) {  
    return FutureBuilder(
      future: fetchQuestions(),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          List<Question> questions = snapshot.data as List<Question>;
          return QuestionPage(questions: questions);
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Quiz App"),
            ),
            body: const Center(
              child: Text("Request Failed"),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text("Quiz App"),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }),
    );
  }
}

class QuestionPage extends StatefulWidget {
  final List<Question> questions;
  const QuestionPage({Key? key, required this.questions}) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final List<String> _selectedAnswers = [];

  int _index = 0;

  List<String> get _correctAnswers {
    List<String> correctAnswers = [];
    for (var i = 0; i < widget.questions.length; i++) {
      correctAnswers.add(widget.questions[i].correctAnswer!);
    }
    return correctAnswers;
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedAnswers.isEmpty ||
        _selectedAnswers.length != _correctAnswers.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Quiz App"),
        ),
        body: QuestionView(
          question: widget.questions[_index],
          onValueChanged: (value) {
            setState(() {
              _selectedAnswers.add(value);
            });
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() {
            if (_index < 2) {
              _index++;
            }
          }),
          child: const Icon(Icons.chevron_right_rounded),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz App"),
      ),
      body: ResultPage(
          correctAnswers: _correctAnswers, selectedAnswers: _selectedAnswers),
    );
  }
}

class QuestionView extends StatefulWidget {
  final Question question;
  final ValueChanged<String> onValueChanged;
  const QuestionView({
    Key? key,
    required this.question,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  String? _selctedOption;
  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
          unescape.convert(widget.question.question!),
          style: TextStyle(fontSize: 20),
        ),
        for (var option in widget.question.option!)
          ListTile(
            title: Text(unescape.convert(option)),
            leading: Radio<String>(
              value: option,
              groupValue: _selctedOption,
              onChanged: (value) {
                setState(() {
                  _selctedOption = value;
                  widget.onValueChanged(value!);
                });
              },
            ),
          ),
      ]),
    );
  }
}

class ResultPage extends StatelessWidget {
  final List<String> correctAnswers;
  final List<String> selectedAnswers;
  const ResultPage({
    Key? key,
    required this.correctAnswers,
    required this.selectedAnswers,
  }) : super(key: key);

  int get score {
    int score = 0;
    for (var i = 0; i < correctAnswers.length; i++) {
      if (correctAnswers[i] == selectedAnswers[i]) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your Score is $score',
        style: const TextStyle(
          color: Colors.black38,
          fontSize: 24,
        ),
      ),
    );
  }
}
