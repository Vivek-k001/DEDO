// GENERATED CODE - Manual TypeAdapter for TrackList
// ignore_for_file: type=lint

part of 'track_list.dart';

class TrackListAdapter extends TypeAdapter<TrackList> {
  @override
  final int typeId = 4;

  @override
  TrackList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackList(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      categoryId: fields[3] as String?,
      colorValue: fields[4] as int,
      statusOptions: (fields[5] as List).cast<String>(),
      defaultStatus: fields[6] as String,
      completedStatus: fields[7] as String,
      items: (fields[8] as List).cast<TrackItem>(),
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TrackList obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.colorValue)
      ..writeByte(5)
      ..write(obj.statusOptions)
      ..writeByte(6)
      ..write(obj.defaultStatus)
      ..writeByte(7)
      ..write(obj.completedStatus)
      ..writeByte(8)
      ..write(obj.items)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

