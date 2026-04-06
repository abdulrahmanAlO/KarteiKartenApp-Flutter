import 'package:flutter/material.dart';
import 'package:flutter_application_final_project/Modells/Karte.dart';
import 'package:flutter_application_final_project/Modells/UserServices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quick_quiz/quick_quiz.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

//QuizEinleitung
class QuizIntroduction extends StatelessWidget {
  const QuizIntroduction({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Quiz Creation",
          body:
              "This screen explains how the quiz creation process works,for a card one Quiz and unlimited Quitions and 6 options.",
          image: Icon(Icons.quiz, size: 120),
        ),
        PageViewModel(
          title: "Save and Next",
          body:
              "When you click \"Save and Next\", your quiz will be saved and "
              "you will proceed to the next question.\n\n"
              "Saved questions cannot be edited. If you click the remove button, the entire quiz will be removed.",

          image: Icon(Icons.navigate_next, size: 120),
        ),
        PageViewModel(
          title: "Save and Break",
          body:
              "When you click \"Save and Break\", the quiz creation "
              "process ends.\n\n"
              "You will return to the Card Page. When you click quiz creation again, you can add more questions to this card (same quiz).",
          image: Icon(Icons.stop_circle, size: 120),
        ),
      ],

      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Text("Next"),
      done: const Text("Start Quiz"),

      onDone: () {
        Navigator.pop(context); // zurück zur Quizpage
      },
      onSkip: () {
        Navigator.pop(context);
      },
    );
  }
}

//Quiz anzeigen
class Quizpage extends StatefulWidget {
  final int? karteId;
  final bool? rolle;

  const Quizpage({super.key, required this.karteId, required this.rolle});

  @override
  State<Quizpage> createState() => _Quizpage();
}

class _Quizpage extends State<Quizpage> {
  late dynamic quiz;
  late List<QuestionModel> questions = [];
  //Die Varaiblen
  // PostgrestList? quiz;
  List<TextEditingController> Options = [];
  List<String> extractedOptions = [];
  final TextEditingController _quitionEditingController =
      TextEditingController();
  final TextEditingController _optionsEditingController =
      TextEditingController();
  final TextEditingController _answerEditingController =
      TextEditingController();

  /*
  //PostgrestList? Karten;
  final user = Supabase.instance.client.auth.currentUser;
  PostgrestMap? _user;
  final TextEditingController _feedbackTextController = TextEditingController();
*/
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.rolle == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizIntroduction()),
        );
      } else {
        loadQuiz();
      }
    });

    reloadList();
  }

  void startNeuQuition() {
    Options.clear();
    _quitionEditingController.clear();
    _answerEditingController.clear();
    _optionsEditingController.clear();

    setState(() {});
  }

  // 1 Fragen 30 S
  int timeduration() {
    return questions.length * 30;
  }

  void addOptios() {
    Options.add(TextEditingController());
  }

  void removeOptions() {
    Options.removeLast();
  }

  static void quizBackendinUI() {}
  List<String> extractControllerToString(List<TextEditingController> options) {
    extractedOptions = Options.map((c) => c.text).toList(); //Note: =>
    return extractedOptions;
  }

  Future<void> loadQuiz() async {
    quiz = await UserServices.getQuizbyId(widget.karteId);
    if (quiz != null && quiz.isNotEmpty) {
      questions = quiz
          .map<QuestionModel>((q) => QuestionModel.fromMap(q))
          .toList(); // Kritikal wiederholen
    } else {
      questions = [];
    }
    setState(() {});
  }

  void reloadList() async {
    if (widget.karteId == null) {
      return;
    } else if (_answerEditingController.text == "") {
      return;
    }
    await UserServices.InsertQuiz(
      widget.karteId,
      _quitionEditingController.text,
      extractedOptions,
      int.tryParse(_answerEditingController.text),
    );

    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    /*Note: die Argument von dem Puschname holen*/

    return Scaffold(
      appBar: widget.rolle == true
          ? AppBar(
              title: const Text('Quiz'),

              actions: [
                IconButton(
                  icon: const Icon(Icons.navigate_next),
                  onPressed: () {
                    extractControllerToString(Options);
                    reloadList();
                    startNeuQuition();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle),
                  onPressed: () async {
                    extractControllerToString(Options);

                    Navigator.pop(
                      context,
                    ); // nur, wenn du wirklich den aktuellen Screen schließen willst
                    reloadList();
                  },
                ),

                const SizedBox(height: 16),

                IconButton(
                  onPressed: () async {
                    //prüfe ob Quiz gelöscht werden kann
                    if (!await UserServices.removeQuiz(widget.karteId)) {
                      // Meldung an den User
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Quiz is Empty")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Quiz is removed")),
                      );
                      // nur, wenn du wirklich den aktuellen Screen schließen willst
                    }
                    Navigator.pop(context);
                    reloadList();
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            )
          : AppBar(title: const Text('Quiz')),
      body: widget.rolle == true
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Your Notes → nimmt den verfügbaren Platz
                  TextField(
                    controller: _quitionEditingController,
                    decoration: InputDecoration(
                      labelText: "Question",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: Options
                          .length, //Note: das muss getzt werden sonst wird builder nicht die neuen Elmenete anzeigen
                      itemBuilder: (context, index) {
                        return Padding(
                          //Note: das muss getzt werden sonst wird builder nicht die neuen Elmenete anzeigen
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TextField(
                            controller: Options[index],

                            decoration: InputDecoration(
                              labelText: "options $index",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextField(
                    controller: _answerEditingController,
                    decoration: InputDecoration(
                      labelText: "which one is correct? ",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: Text("Add new Options"),
                    onPressed: () {
                      addOptios();
                      setState(() {});
                      //                  reloadList();
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: Text("remove Options"),
                    onPressed: () {
                      removeOptions();
                      setState(() {});
                      //                  reloadList();
                    },
                  ),
                ],
              ),
            )
          : (questions.isNotEmpty)
          ? QuizPage(
              quiz: Quiz(questions: questions, timerDuration: timeduration()),
            )
          : Center(child: Text("There ist no Quiz")),
    );
  }
}
