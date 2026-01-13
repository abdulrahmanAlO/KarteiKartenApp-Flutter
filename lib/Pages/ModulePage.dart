import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_final_project/Modells/Karte.dart';
import 'package:flutter_application_final_project/Modells/Login.dart';
import 'package:flutter_application_final_project/Modells/UserServices.dart';
import 'package:flutter_application_final_project/Pages/ThemaPages.dart';
import 'package:flutter_application_final_project/theme/app_theme.dart';
import 'package:flutter_application_final_project/utils/animations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModulePage extends StatefulWidget {
  final String title;
  const ModulePage({super.key, required this.title});
  @override
  State<ModulePage> createState() => _ModulePage();
}

class _ModulePage extends State<ModulePage>
    with SingleTickerProviderStateMixin {
  //Variablen:
 
  PostgrestList? Studiengang = List.empty();
  PostgrestList? StudiengangUI = List.empty();
  PostgrestList? Module = List.empty();
  PostgrestList? studentsRelatedLecturer = List.empty();
  String nameUI = " ";
  PostgrestList? ModuleUI = List.empty();
  final user = Supabase.instance.client.auth.currentUser;
  PostgrestMap? _user;
  final TextEditingController _todoTextController = TextEditingController();
  late AnimationController _animationController;
  int? StudnetId;
  //end Variablen

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadUI();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void reloadList() {
    nameUI = _user?["name"];
    StudiengangUI = Studiengang;
    ModuleUI = Module;
    setState(() {});
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Navigate to login page
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/Login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: ${e.toString()}')),
        );
      }
    }
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) => AppAnimations.fadeIn(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $nameUI'),
              const SizedBox(height: 8),
              Text('Email: ${user?.email ?? 'N/A'}'),
              const SizedBox(height: 8),
              if (StudiengangUI != null && StudiengangUI!.isNotEmpty)
                Text('Program: ${StudiengangUI![0]["name"]}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _loadModul() async {
    Module = await UserServices.loadSubjcts(_user?["id"]);
    reloadList();
    return;
  }

  void _loadUI() async {
    _user = await UserServices.loadPerson(user) as PostgrestMap;
    Studiengang = await UserServices.loadPrograms(_user?["Programm_id"]);

    if (Studiengang != null && !_user?["IsLecturer"]) {
      _loadModul();
    } else {
      Module = [];
    }
    if (_user?["IsLecturer"]) {
     
      studentsRelatedLecturer = await UserServices.loadallStudentsRelatedDozent(
        _user?["Programm_id"],
      );
    } 

    reloadList();
  }

  void _LecturerLoadModuleRelatedStudent(int StudnetId) async {
    Module = await UserServices.loadSubjcts(StudnetId);
    reloadList();
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
                  "Add New Module",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _todoTextController,
                  decoration: const InputDecoration(
                    labelText: "Enter module name here",
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
                      child: const Text("Add Module"),
                      onPressed: () async {
                        if (_todoTextController.text != "") {
                          Karte thema = Karte(
                            description: _todoTextController.text,
                          );
                          if (_user?["IsLecturer"] == true &&
                              StudnetId != null) {
                            await UserServices.insertSubject(
                              thema.description,
                              StudiengangUI?[0]["id"],
                              StudnetId!,
                            );
                             Navigator.pop(context, true);
                            _LecturerLoadModuleRelatedStudent(StudnetId!);
                            return ;
                          } else {
                            await UserServices.insertSubject(
                              thema.description,
                              StudiengangUI?[0]["id"],
                              _user?["id"],
                            );
                              Navigator.pop(context, true);
                            _loadUI();
                            return ;
                          }
                         
                        }

                       
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

  StatefulBuilder todoEditDialog(BuildContext context, PostgrestMap modul) {
    _todoTextController.text = modul["name"];
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
                  "Edit Topic",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _todoTextController,
                  decoration: const InputDecoration(
                    labelText: "Enter topic name here",
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
                        Karte card = Karte(
                          description: _todoTextController.text,
                        );
                        await UserServices.updateSubjctsRelated(
                          modul["id"],
                          card.description,
                          "Theme",
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
    final bool isLecturer = _user?["IsLecturer"] == true;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout_outlined),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Welcome:"),
            const SizedBox(height: 4),
            Text(
              nameUI,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showProfile,
            tooltip: 'Profile',
          ),
        ],
      ),
      body: isLecturer && StudnetId != null || !isLecturer
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ModuleUI!.length,
              itemBuilder: (context, index) {
                final PostgrestMap modul = ModuleUI![index];

                return AnimatedListItem(
                  index: index,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          AppAnimations.slideRoute(ThemaPages(modul: modul)),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.book,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Modul Name
                            Expanded(
                              child: Text(
                                modul["name"] ?? "",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Edit/Delete Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          todoEditDialog(context, modul),
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await UserServices.deleteSubjctsRelated(
                                      modul,
                                      "modules",
                                    );

                                    if (isLecturer && StudnetId != null) {
                                      _LecturerLoadModuleRelatedStudent(
                                        StudnetId!,
                                      );
                                    } else {
                                      _loadModul();
                                    }
                                  },
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete',
                                  color: Colors.red,
                                ),
                              ],
                            ),

                            // Pfeil rechts
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : isLecturer && StudnetId == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'select student',
                    border: OutlineInputBorder(),
                  ),
                  value: StudnetId,
                  items: studentsRelatedLecturer!.map((student) {
                    return DropdownMenuItem<int>(
                      value: student['id'],
                      child: Text(student['name']),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value == null) return;

                    StudnetId = value;
                    _LecturerLoadModuleRelatedStudent(StudnetId!);
                  },
                ),
              ),
            )
          : Center(
              child: AppAnimations.fadeIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No modules available",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Neuer Button links vom Add Module
          Padding(
            padding: const EdgeInsets.only(
              right: 200.0,
              bottom: 0,
            ), // Abstand nach links
            child: isLecturer && StudnetId != null
                ? FloatingActionButton.extended(
                    heroTag: 1,
                    onPressed: () {
                      StudnetId = null;
                      setState(() {});
                      //  Module = [];
                      //reloadList();
                      print(
                        "Change Student Button Pressed",
                      ); // Hier die Aktion für den Button
                    },
                    icon: const Icon(Icons.person),
                    label: const Text("Change Student"),
                  )
                : null,
          ),
          // Original Add Module Button
          ?!isLecturer || isLecturer && StudnetId != null
              ? FloatingActionButton.extended(
                  heroTag: 2,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => todoAddDialog(context),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Module"),
                )
              : null,
        ],
      ),
    );
  }
}
