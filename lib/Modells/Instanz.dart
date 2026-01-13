import 'package:supabase_flutter/supabase_flutter.dart';

class Instanz {
  //final index;
  //final DateTime ? selectedDate;
  /*
  static Map<String, dynamic>? jsonData;

  static Future<void> _ensureloaded() async{
    if (jsonData == null) {
      await loadJson();
    }
  }

  static Future<void> loadJson() async {
    if (jsonData == null) {
      final String jsonString = await rootBundle.loadString(
        'assets/supabse.json',
      );
      jsonData = json.decode(jsonString);
    }
  }
*/
  static Future<List<Map<String,dynamic>>> getStudent() async {
    // damit wir das als Singeton benutzen
    /*
 await _ensureloaded();
    final StudenTable = (jsonData!["students"] as List)
    .cast<Map<String, dynamic>>();
    
    return StudenTable;
    */
    return  await Supabase.instance.client.from("Studnet").select();
  }

  static Future<List<Map<String,dynamic>>> getDozent() async {
    /*
  await _ensureloaded();
    final DoznetTable = (jsonData!["lecturers"] as List)
    .cast<Map<String, dynamic>>();
    return DoznetTable;
    */
    return  await Supabase.instance.client.from("Lecturer").select();

  }
   static Future<List<Map<String,dynamic>>> getuniversities() async {
    /*
    // damit wir das als Singeton benutzen
  await _ensureloaded();
    final UnisTable = (jsonData!["universities"] as List)
    .cast<Map<String, dynamic>>();
    return UnisTable;
    */
     return  await Supabase.instance.client.from("universities").select();
  }

  static Future<List<Map<String,dynamic>>> getprograms() async {
    /*
   await _ensureloaded();
    final ProgramTable = (jsonData!["programs"] as List)
    .cast<Map<String, dynamic>>();
    return ProgramTable;
    */
    return  await Supabase.instance.client.from("programs").select();
  }

   static Future<List<Map<String,dynamic>>>  getmodules() async {
    /*
    // damit wir das als Singeton benutzen
  await _ensureloaded();
    final ModulesTable = (jsonData!["modules"] as List)
    .cast<Map<String, dynamic>>();
    return ModulesTable;
    */
    return  await Supabase.instance.client.from("modules").select();
  }

/*
  static Future<List<Map<String,dynamic>>>  getmodelstudent() async {
  await  _ensureloaded();
    final modelstudent = (jsonData!["student_modules"] as List)
    .cast<Map<String, dynamic>>();
    return modelstudent;
  }

   static Future<List<Map<String,dynamic>>>  getlecturermodules() async {
  await _ensureloaded();
    final lecturermodules =(jsonData!["lecturer_modules"] as List)
    .cast<Map<String, dynamic>>();
    return lecturermodules;
  }
   static Future<List<Map<String,dynamic>>> getlecturerprograms() async {
 await  _ensureloaded();
    final lecturerprograms = (jsonData!["lecturer_programs"] as List)
    .cast<Map<String, dynamic>>();
    return lecturerprograms;
  }
   static Future<List<Map<String,dynamic>>> getstudentprograms() async {
  await _ensureloaded();
    final studentprograms = (jsonData!["student_programs"] as List)
    .cast<Map<String, dynamic>>();
    return studentprograms;
  }
  /*
  Future<List<dynamic>> getMenuMensa()async{
    final jsonData = await loadJson();

    String str = index.toString();
    // welsche Mensa 
     return (jsonData["menus"] as List<dynamic>)[index]["weeklyMenu"] as List<dynamic>;

  }
  */
  */
}
