import 'Instanz.dart';

class Login {
 
  // Students eingelogt
  static var loadStudentDozent;
  static  Future<Map<String, dynamic>> autification(
      
    String name,
    String pass,
    bool studentDozent,
  ) async {
    
    if (studentDozent == false) {
      loadStudentDozent = await Instanz.getStudent();
    } else {
      loadStudentDozent =await Instanz.getDozent();
    }
    /*
    String _kryptopass = sha256
        .convert(
          utf8.encode(pass) +
              List.generate(16, (_) => Random.secure().nextInt(10000)),
        )
        .toString();
        print(_kryptopass);
*/
    for (var s in loadStudentDozent) {
      if (s["name"] == name) {
      
        if (s["password"] == pass) {
          // autification richtige
         
          return s;
        } else {
          print("Fehlerhafte Passwort");
        }
      }

    }
    return <String, dynamic>{}; //Null
  }

}
