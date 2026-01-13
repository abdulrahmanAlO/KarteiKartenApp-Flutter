import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';


part 'Notiz.g.dart';

@HiveType(typeId: 0)
class Notiz extends HiveObject {
@HiveField(0)
 String uuid = "";
@HiveField(1)
int id;
@HiveField(2)
String title;
 @HiveField(3)
int module_id;
 @HiveField(4)
int student_id;
 @HiveField(5)
String body;
 @HiveField(6)
String feedback;
Notiz({required this.id, required this.title,required this.module_id,required this.student_id,required this.body,required this.feedback}):
uuid = Uuid().v4();
}
//Execute 'dart run build_runner build' to generate the type adaptors