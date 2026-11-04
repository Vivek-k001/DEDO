// GENERATED CODE - Manual TypeAdapter for TrackItem
// ignore_for_file: type=lint

part of 'track_item.dart';

class TrackItemAdapter extends TypeAdapter<TrackItem> {
  @override
  final int typeId = 5;

  @override
  TrackItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackItem(
      id: fields[0] as String,
      name: fields[1] as String,
      status: fields[2] as String,
      note: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TrackItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

