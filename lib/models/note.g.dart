// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      uuid: fields[0] as String,
      title: fields[1] as String,
      content: (fields[2] as List).cast<NoteContent>(),
      color: fields[3] as String,
      pinned: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.pinned)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteContentAdapter extends TypeAdapter<NoteContent> {
  @override
  final int typeId = 1;

  @override
  NoteContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteContent(
      type: fields[0] as String?,
      value: fields[1] as String?,
      label: fields[2] as String?,
      checked: fields[3] as bool?,
      url: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NoteContent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.checked)
      ..writeByte(4)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
