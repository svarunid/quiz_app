class Question {
  String? difficulty;
  String? question;
  String? correctAnswer;
  List<String>? option;

  Question({this.correctAnswer, this.difficulty, this.option, this.question});

  Question.fromJson(json)
      : correctAnswer = json["correct_answer"],
        difficulty = json["difficulty"],
        option = [...json["incorrect_answers"], json["correct_answer"]],
        question = json["question"];
}
