
import 'package:uuid/uuid.dart';
class Karte {
  static final Uuid _uuid = Uuid(); // KI Hilfe

  String id;
  final String description;
   String feedback;
   String title;
  Karte({required this.description,String ? feedback, String? title}):feedback = feedback ?? "",title = title ?? "",id = _uuid.v4();
    // Add todo in hive

}