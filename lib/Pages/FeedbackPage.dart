import 'package:flutter/material.dart';
import 'package:flutter_application_final_project/Modells/Karte.dart';
import 'package:flutter_application_final_project/Modells/UserServices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackPage extends StatefulWidget {
  final String? kartename;
  final PostgrestMap? karte;
  const FeedbackPage({super.key, required this.karte, required this.kartename});
  @override
  State<FeedbackPage> createState() => _FeedbackPage();
}

class _FeedbackPage extends State<FeedbackPage> {
  //PostgrestList? Karten;
  final user = Supabase.instance.client.auth.currentUser;
  PostgrestMap? _user;
  final TextEditingController _feedbackTextController = TextEditingController();

  @override
  void initState() {
    reloadList();
    super.initState();
  }

  void reloadList() async {
    _user = await UserServices.loadPerson(user) as PostgrestMap;

    if (widget.karte != null && widget.karte!.isNotEmpty) {
      _feedbackTextController.text = widget.karte!["feedback"];
    } else {
      _feedbackTextController.text = "";
    }
    setState(() {});
  }

  Future<void> check(Karte card) async {
    if (widget.karte != null && widget.karte!.isNotEmpty) {
    await   UserServices.updateKarte(card, widget.karte!["SubSubTheme_id"]);
    } else {
      throw Exception("Student has no note yet");
    }
    reloadList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(children: [Text("${widget.kartename}")]),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_user?['IsLecturer'] == true)
            IconButton(
              tooltip: 'save',
              icon: const Icon(Icons.save),
              onPressed: () {
                Karte card = Karte(
                  description: widget.karte?["Notiz"],
                  feedback: _feedbackTextController.text,
                );
                check(card);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TextField(
                controller: _feedbackTextController,
                readOnly: !(_user?["IsLecturer"] ?? false),
                expands: true,
                minLines: null,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "Your Notes",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
