// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Notiz.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotizAdapter extends TypeAdapter<Notiz> {
  @override
  final typeId = 0;

  @override
  Notiz read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notiz(
      id: (fields[1] as num).toInt(),
      title: fields[2] as String,
      module_id: (fields[3] as num).toInt(),
      student_id: (fields[4] as num).toInt(),
      body: fields[5] as String,
      feedback: fields[6] as String,
    )..uuid = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, Notiz obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.module_id)
      ..writeByte(4)
      ..write(obj.student_id)
      ..writeByte(5)
      ..write(obj.body)
      ..writeByte(6)
      ..write(obj.feedback);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotizAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
