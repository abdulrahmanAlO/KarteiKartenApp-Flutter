import 'package:flutter/material.dart';
import 'package:flutter_application_final_project/Modells/Karte.dart';
import 'package:flutter_application_final_project/Modells/UserServices.dart';
import 'package:flutter_application_final_project/Pages/SubSubThemaPages.dart';
import 'package:flutter_application_final_project/theme/app_theme.dart';
import 'package:flutter_application_final_project/utils/animations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubThemaPages extends StatefulWidget {
  final PostgrestMap Thema;
  const SubThemaPages({super.key, required this.Thema});
  @override
  State<SubThemaPages> createState() => _SubThemaPages();
}

class _SubThemaPages extends State<SubThemaPages> {
  PostgrestList? subThemen = List.empty();
  final TextEditingController _todoTextController = TextEditingController();

  @override
  void initState() {
    reloadList();
    super.initState();
  }

  void reloadList() async {
    subThemen = await UserServices.loadSubjctsRelated(
      widget.Thema["id"],
      "SubTheme",
    );
    setState(() {});
  }

  StatefulBuilder todoAddDialog(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Subtopic",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _todoTextController,
                  decoration: const InputDecoration(
                    labelText: "Enter subtopic name here",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        _todoTextController.clear();
                        Navigator.pop(context, true);
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text("Add Subtopic"),
                      onPressed: () async {
                        if (_todoTextController.text != "") {
                          Karte thema = Karte(
                            description: _todoTextController.text,
                          );
                        await   UserServices.insertSubjctsRelated(
                            thema.description,
                            widget.Thema["id"],
                            "SubTheme",
                          );
                        }
                        Navigator.pop(context, true);
                        reloadList();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  StatefulBuilder todoEditDialog(
    BuildContext context,
    PostgrestMap subThema,
    int index,
  ) {
    _todoTextController.text = subThema["name"];
    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Subtopic",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _todoTextController,
                  decoration: const InputDecoration(
                    labelText: "Enter subtopic name here",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        _todoTextController.clear();
                        Navigator.pop(context, true);
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text("Save"),
                      onPressed: () async {
                        Karte card = Karte(description: _todoTextController.text);
                    await     UserServices.updateSubjctsRelated(
                          subThema["id"],
                          card.description,
                          "SubTheme",
                        );
                        Navigator.pop(context, true);
                        reloadList();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(children: [Text("${widget.Thema["name"]}")]),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: subThemen!.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subThemen!.length,
              itemBuilder: (context, index) {
                PostgrestMap subThema = subThemen![index];

                return AnimatedListItem(
                  index: index,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.subdirectory_arrow_right,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        subThema["name"],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        AppAnimations.slideRoute(
                          SubSubThemaPages(subThema: subThema),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    todoEditDialog(context, subThema, index),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () async {
                           await    UserServices.deleteSubjctsRelated(
                                subThema,
                                "SubTheme",
                              );
                              reloadList();
                            },
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: AppAnimations.fadeIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No subtopics available",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => todoAddDialog(context),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Subtopic"),
      ),
    );
  }
}
