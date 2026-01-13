import 'package:flutter/material.dart';
import 'package:flutter_application_final_project/Modells/Karte.dart';
import 'package:flutter_application_final_project/Modells/UserServices.dart';
import 'package:flutter_application_final_project/Pages/FeedbackPage.dart';
import 'package:flutter_application_final_project/Pages/QuizPage.dart';
import 'package:flutter_application_final_project/utils/animations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Kartenpages extends StatefulWidget {
  final PostgrestMap? subSubTheme;
  const Kartenpages({super.key, required this.subSubTheme});
  @override
  State<Kartenpages> createState() => _Kartenpages();
}

class _Kartenpages extends State<Kartenpages> {
  PostgrestList? Karten;
  final user = Supabase.instance.client.auth.currentUser;
  PostgrestMap? _user;
  final TextEditingController _todoTextController = TextEditingController();
  final TextEditingController _feedbackTextController = TextEditingController();

  @override
  void initState() {
    reloadList();
    super.initState();
  }

  void reloadList() async {
    Karten = (await UserServices.loadKarte(widget.subSubTheme!["id"]));
    _user = await UserServices.loadPerson(user) as PostgrestMap;
    if (Karten != null && Karten!.isNotEmpty) {
      _todoTextController.text = Karten![0]["Notiz"];
    } else {
      _todoTextController.text = "";
    }
    if (Karten != null && Karten!.isNotEmpty) {
      _feedbackTextController.text = Karten![0]["feedback"];
    } else {
      _feedbackTextController.text = "";
    }
    if (!mounted) return;
    setState(() {});
  }

  /*Model*/
  Future<void> check(Karte card) async {
    if (Karten != null && Karten!.isNotEmpty) {
      //   print("Update");
     await  UserServices.updateKarte(card, Karten![0]["SubSubTheme_id"]);
    } else {
      //  print("Insert");
    await   UserServices.InsertKarte(card, widget.subSubTheme!["id"]);
    }
    reloadList();
  }

  Future<void> showFileDialog(
    BuildContext context,
    int cardId,
    bool rolle,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Download Files'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder<List<FileObject>>(
                      future:  UserServices.loadUploadedFile(cardId, rolle),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 100,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text(
                            'No files available',
                            textAlign: TextAlign.center,
                          );
                        }

                        final files = snapshot.data!;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: files.map((file) {
                            final fileName = file.name
                                .split(RegExp(r'[\\/]|_'))
                                .last;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.download),
                                label: Text(fileName),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () async {
                                  await UserServices.downloadFilebyId(
                                    cardId,
                                    file.name,
                                    rolle,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$fileName downloaded'),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                  }
                                  Navigator.pop(context);
                                  return;
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Abbrechen Button zentriert
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // actions leer lassen, sonst ist er automatisch rechts
              actions: null,
            );
          },
        );
      },
    );
  }

  Future<void> showDialogUpload(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Upload File'),
              content: const Text(
                "Choose an upload option:",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload to Database'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        if (Karten == null || Karten!.isEmpty) {
                          Navigator.pop(context);
                         // if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please save the card first"),
                            ),
                          );
                          return;
                        }

                        if (_user?['IsLecturer'] == true) {
                          await UserServices.uploadFilebyId(
                            Karten![0]['id'],
                            true,
                          );
                        } else {
                          await UserServices.uploadFilebyId(
                            Karten![0]['id'],
                            false,
                          );
                        }
                      
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File uploaded to database'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        

                        Navigator.pop(context);
                        return;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.subSubTheme!["name"]}"),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Save Button
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save),
            onPressed: () {
              Karte card = Karte(
                description: _todoTextController.text,
                feedback: _feedbackTextController.text,
              );
              check(card);
           
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Card saved'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            },
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.file_open),
            onSelected: (value) async {
              if (value == 'upload') {
                showDialogUpload(context);
              } else if (value == 'download') {
                if (Karten == null && Karten!.isNotEmpty) {
                
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No card available.")),
                  );
                } else {
                  await showFileDialog(
                    context,
                    Karten![0]['id'],
                    _user?['IsLecturer'] == true,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'upload', child: Text('Upload-PDF')),
              const PopupMenuItem(
                value: 'download',
                child: Text('Download-PDF'),
              ),
            ],
          ),

          // Delete Button
          IconButton(
            tooltip: 'Delete Card',
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (Karten != null && Karten!.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Card'),
                    content: const Text(
                      'Are you sure you want to delete this card?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                       await    UserServices.deleteSubjctsRelated(
                            Karten![0],
                            "Karte",
                          );
                          reloadList();
                          Navigator.pop(context); // Dialog schließen
                          Navigator.pop(context); // KartenPage schließen
                         // if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Card deleted'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              } else {
                //if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No card available to delete")),
                );
              }
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
                controller: _todoTextController,
                readOnly: _user?["IsLecturer"] ?? true,
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

            const Spacer(), // schiebt alles nach unten
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.feedback),
                    label: const Text('Feedback'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (Karten == null || Karten!.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please save the card first"),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          AppAnimations.slideRoute(
                            FeedbackPage(
                              karte: Karten?[0],
                              kartename: widget.subSubTheme!["name"],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      (_user?['IsLecturer'] != null &&
                          _user?['IsLecturer'] == true)
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.quiz),
                          label: const Text('Create Quiz'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (Karten == null || Karten!.isEmpty) {
                             // if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please save the card first"),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                AppAnimations.slideRoute(
                                  Quizpage(
                                    karteId: Karten?[0]['id'],
                                    rolle: true,
                                  ),
                                ),
                              );
                            }
                          },
                        )
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle),
                          label: const Text('start Quiz'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (Karten == null || Karten!.isEmpty) {
                            //  if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "please save the card first",
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                AppAnimations.slideRoute(
                                  Quizpage(
                                    karteId: Karten?[0]['id'],
                                    rolle: false,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
