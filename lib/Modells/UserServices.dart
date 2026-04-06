import 'dart:io';

import 'package:flutter/services.dart';

import 'package:flutter_application_final_project/Modells/Karte.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

import 'package:file_save_directory/file_save_directory.dart';

class UserServices {
  static Future<void> loadDokumentTobeUploaded(
    String assetsPath,
    final user,
  ) async {
    final data = await rootBundle.load(assetsPath);
    final bytes = data.buffer.asUint8List(); // Umwandeln in Bytes
    final dateiName = assetsPath.split('/').last;
    // Datei speichern
    await FileSaveDirectory.instance.saveFile(
      fileName: dateiName,
      fileBytes: bytes,
      location: SaveLocation.documents,
      openAfterSave: false,
    );

    /*
    //Ordner erzeugen in dem Datei-App
    final file = getApplicationDocumentsDirectory();
    final FileName = assetsPath.split('/').last;
    final filePath = File('$file/$FileName');
     if(await filePath.exists()){
      return;
     }
     //Daten von der Assets lesen und in der Datei schreiben
     final data = await rootBundle.load(assetsPath);
     final bytes = data.buffer.asUint8List();
   await  filePath.writeAsBytes(bytes);
*/
  }

  static Future<PostgrestMap?> loadPerson(dynamic user) async {
    if (user == null) return null;

    // Zuerst Student-Tabelle prüfen
    var user0 = await UserServices.loadStudent(user.id);

    // Wenn Student nicht gefunden, Lecturer prüfen
    if (user0 != null) {
    } else {
      user0 = await UserServices.loadLecturer(user.id);
    }
    if (user0 == null) {
      return null; // Abbrechen, kein User
    }

    return user0;
  }

  static Future<PostgrestList> loadallStudentsRelatedDozent(int progId) async {
    return await Supabase.instance.client
        .from('Student')
        .select()
        .eq('Programm_id', progId);
  }

  static Future<PostgrestMap?> loadStudent(String uid) async {
    try {
      final student = await Supabase.instance.client
          .from('Student')
          .select()
          .eq('UID', uid)
          .maybeSingle();
      return student;
    } catch (e) {
      throw Exception("Fehler bei LoadStudent: {$e}");
    }
  }

  static Future<PostgrestMap?> loadLecturer(String uid) async {
    try {
      final lecturer = await Supabase.instance.client
          .from('Lecturer')
          .select()
          .eq('UID', uid)
          .maybeSingle();
      return lecturer;
    } catch (e) {
      throw Exception("Fehler bei loadLecturer: {$e}");
    }
  }

  static Future<PostgrestList?> loadPrograms(int pid) async {
    try {
      final programs = await Supabase.instance.client
          .from('programs')
          .select()
          .eq('id', pid);
      return programs;
    } catch (e) {
      throw Exception("Fehler bei loadPrograms: {$e}");
    }
  }

  static Future<PostgrestList?> loadSubjcts(int pid) async {
    try {
      final subjects = await Supabase.instance.client
          .from('modules')
          .select()
          .eq('student_Id', pid);
      return subjects;
    } catch (e) {
      throw Exception("Fehler bei loadPrograms: {$e}");
    }
  }

  static Future<void> insertSubject(String name, int pid, int uid) async {
    try {
      await Supabase.instance.client.from("modules").insert({
        'name': name,
        'program_id': pid,
        'student_Id': uid,
      });
    } catch (e) {
      throw Exception("Fehler bei loadPrograms: {$e}");
    }
  }

  static Future<void> insertSubjctsRelated(
    String name,
    int id,
    String tabelle,
  ) async {
    String relation = getRelations(tabelle);
    try {
      await Supabase.instance.client.from(tabelle).insert({
        'name': name,
        relation: id,
      });
    } catch (e) {
      throw Exception("Fehler bei Thema Faild: {$e}");
    }
  }

  static Future<PostgrestList?> loadSubjctsRelated(
    int id,
    String tabelle,
  ) async {
    String relation = getRelations(tabelle);
    try {
      final thema = await Supabase.instance.client
          .from(tabelle)
          .select()
          .eq(relation, id);
      return thema;
    } catch (e) {
      throw Exception("Fehler bei loadPrograms: {$e}");
    }
  }

  static Future<void> deleteSubjctsRelated(
    PostgrestMap thema,
    String tabelle,
  ) async {
    try {
      await UserServices.removeFilesRelatedCards(tabelle, thema["id"]);
      await Supabase.instance.client
          .from(tabelle)
          .delete()
          .eq('id', thema["id"]);

      return;
    } catch (e) {
      throw Exception("Fehler bei loadPrograms: {$e}");
    }
  }

  static Future<void> updateSubjctsRelated( //
    int id,
    String name,
    String tabelle,
  ) async {
    try {
      await Supabase.instance.client
          .from(tabelle)
          .update({'name': name})
          .eq('id', id);
      return;
    } catch (e) {
      throw Exception("Fehler bei loadPrograms: {$e}");
    }
  }

  static String getRelations(String tabelle) {
    switch (tabelle) {
      case "Theme":
        return 'modul_id';
      case "SubTheme":
        return 'Theme_id';
      case "SubSubTheme":
        return 'SubTheme_id';
      case "Karte":
        return 'SubSubTheme_id';
    }
    return "";
  }

  static Future<void> InsertKarte(Karte card, int id) async {
    try {
      await Supabase.instance.client.from("Karte").insert({
        'Notiz': card.description,
        'SubSubTheme_id': id,
        'feedback': card.feedback,
      });
      return;
    } catch (e) {
      throw Exception("Fehler bei loadPrograms: {$e}");
    }
  }

  static Future<void> updateKarte(Karte card, int id) async {
    try {
      await Supabase.instance.client
          .from("Karte")
          .update({'Notiz': card.description, 'feedback': card.feedback})
          .eq('SubSubTheme_id', id);
      return;
    } catch (e) {
      throw Exception("Fehler bei loadPrograms: {$e}");
    }
  }

  static Future<PostgrestList?> loadKarte(int id) async {
    try {
      var Karte = await Supabase.instance.client
          .from('Karte')
          .select()
          .eq('SubSubTheme_id', id);
      return Karte;
    } catch (e) {
      throw Exception("Fehler bei Load Karte: {$e}");
    }
  }

  static Future<void> uploadFilebyId(int cardId, bool rolle) async {
    try {
      String rollenOrdner = "";
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      // extrahiere die PDF Datei
      File file = File(result!.files.single.path!);
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      if (rolle == false) {
        rollenOrdner = "Student";
      } else {
        rollenOrdner = "Lecturer";
      }
      String pathbucket = '$cardId/$rollenOrdner/$fileName';
      Uint8List bytes = await file.readAsBytes();
      await Supabase.instance.client.storage
          .from('space-cat.pdf')
          .uploadBinary(
            pathbucket,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
    } catch (e) {
      throw Exception("PickPDF : $e");
    }
  }

  static Future<void> downloadFilebyId(
    int cardId,
    String name,
    bool rolle,
  ) async {
    String Ordner = "";
    if (rolle == true) {
      Ordner = "Student";
    } else {
      Ordner = "Lecturer";
    }
    try {
      String relativePath = '$cardId/$Ordner/$name';
      final response = await Supabase.instance.client.storage
          .from('space-cat.pdf')
          .download(relativePath);

      // Apps dir abrufen
      //final dirApp = await getApplicationDocumentsDirectory();
      // Datei Pfad erstellen
      //  File file = File('${dirApp.path}/$relativePath');
      // Bytes in die Datei schreiben
      //  file.writeAsBytes(response);
      await FileSaveDirectory.instance.saveFile(
        fileName: name,
        fileBytes: response,
        location: (rolle == true)
            ? SaveLocation.downloads
            : SaveLocation.appDocuments,
        openAfterSave: true,
      );
    } catch (e) {
      throw Exception("downloadFilebyId : $e");
    }
  }

  static Future<List<FileObject>>? loadUploadedFile(int id, bool rolle) async {
    String Ordner = "";
    if (rolle == true) {
      Ordner = "Student";
    } else {
      Ordner = "Lecturer";
    }
    return await Supabase.instance.client.storage
        .from('space-cat.pdf')
        .list(path: '$id/$Ordner');
  }

  static Future<void> InsertQuiz(
    int? cardId,
    String quText,
    List<String> options,
    int? anwerId,
  ) async {
    await Supabase.instance.client.from("Quiz").insert({
      'question': quText,
      'options': options,
      'correctAnswerIndex': anwerId as int,
      "Karte_Id": cardId,
    });
  }

  static Future<PostgrestList?> getQuizbyId(int? cardId) async {
    if (cardId != null) {
      final result = await Supabase.instance.client
          .from("Quiz")
          .select()
          .eq("Karte_Id", cardId);
      return result;
    } else {
      throw Exception("getQuizbyId cardId ist NULL ");
    }
  }

  static Future<bool> removeQuiz(int? cardId) async {
    if (cardId != null) {
      var result = await Supabase.instance.client
          .from("Quiz")
          .select()
          .eq("Karte_Id", cardId);
      if (result.isEmpty) {
        return false;
      } else {
        await Supabase.instance.client
            .from("Quiz")
            .delete()
            .eq("Karte_Id", cardId);
        return true;
      }
    }
    return false;
  }

  static Future<void> deleteFilesOfKarte(int karteId) async {
    final storage = Supabase.instance.client.storage.from('space-cat.pdf');

    // Beide Rollen IMMER löschen
    final roles = ['Student', 'Lecturer'];

    for (final role in roles) {
      final path = '$karteId/$role';

      final files = await storage.list(path: path);

      for (final file in files) {
        if (file.name == '.emptyFolderPlaceholder') continue;

        final fullPath = '$path/${file.name}';

        await storage.remove([fullPath]);
      }
    }

    print(' Alle Dateien für Karte $karteId gelöscht');
  }

  // extract and delete all files related to cards of a given table and id
  static Future<void> removeFilesRelatedCards(String tabelle, int id) async {
    try {
      if (tabelle == "Karte") {
        // Nur diese Karte
        await deleteFilesOfKarte(id);
      } else {
        // Wenn Modul / Thema / SubTheme / SubSubTheme
        // Lade zuerst alle untergeordneten Karten
        List<Map<String, dynamic>> cards = [];

        if (tabelle == "SubSubTheme") {
          cards = await Supabase.instance.client
              .from('Karte')
              .select()
              .eq('SubSubTheme_id', id);
        } else if (tabelle == "SubTheme") {
          // SubTheme → SubSubTheme → Karten
          final subSubs = await Supabase.instance.client
              .from('SubSubTheme')
              .select('id')
              .eq('SubTheme_id', id);
          for (var s in subSubs) {
            final karten = await Supabase.instance.client
                .from('Karte')
                .select()
                .eq('SubSubTheme_id', s['id']);
            cards.addAll(karten);
          }
        } else if (tabelle == "Theme") {
          // Theme → SubTheme → SubSubTheme → Karten
          final subThemes = await Supabase.instance.client
              .from('SubTheme')
              .select('id')
              .eq('Theme_id', id);
          for (var st in subThemes) {
            final subSubs = await Supabase.instance.client
                .from('SubSubTheme')
                .select('id')
                .eq('SubTheme_id', st['id']);
            for (var ss in subSubs) {
              final karten = await Supabase.instance.client
                  .from('Karte')
                  .select()
                  .eq('SubSubTheme_id', ss['id']);
              cards.addAll(karten);
            }
          }
        } else if (tabelle == "modules") {
          // Module → Theme → SubTheme → SubSubTheme → Karten
          final themes = await Supabase.instance.client
              .from('Theme')
              .select()
              .eq('modul_id', id);
          for (var t in themes) {
            final subThemes = await Supabase.instance.client
                .from('SubTheme')
                .select()
                .eq('Theme_id', t['id']);
            for (var st in subThemes) {
              final subSubs = await Supabase.instance.client
                  .from('SubSubTheme')
                  .select()
                  .eq('SubTheme_id', st['id']);
              for (var ss in subSubs) {
                final karten = await Supabase.instance.client
                    .from('Karte')
                    .select()
                    .eq('SubSubTheme_id', ss['id']);
                cards.addAll(karten);
              }
            }
          }
        }

        // Alle Dateien der gefundenen Karten löschen
        for (var card in cards) {
          await deleteFilesOfKarte(card['id']);
        }
      }

      return;
    } catch (e) {
      print('keine Karten vorhanden: $e');
      return;
    }
  }
}
