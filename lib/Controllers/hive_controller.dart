
import'package:flutter_application_final_project/Modells/Notiz.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class NotizRepository{
  static final Box<Notiz> _box = Hive.box<Notiz>("NotizBox");

  static void add(Notiz item) => _box.add(item);
  static List<Notiz> getAll() => _box.values.toList();
  static void delete(dynamic key) => _box.delete(key);
  static Notiz? getItem(dynamic key) {
    return _box.get(key);
  }
}
