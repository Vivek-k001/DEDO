// GENERATED CODE - MANUAL HIVE ADAPTER
part of 'sticky_note.dart';

class StickyNoteAdapter extends TypeAdapter<StickyNote> {
  @override
  final int typeId = 3;

  @override
  StickyNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StickyNote(
      id: fields[0] as String,
      content: fields[1] as String,
      colorValue: fields[2] as int,
      createdAt: fields[3] as DateTime,
      rotationAngle: (fields[4] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  void write(BinaryWriter writer, StickyNote obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.rotationAngle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickyNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
