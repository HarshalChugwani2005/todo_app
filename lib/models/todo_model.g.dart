// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      title: fields[0] as String? ?? 'Untitled Task',
      isDone: fields[1] as bool? ?? false,
      category: fields[2] as String? ?? 'Personal',
      dueDate: fields[3] as DateTime?,
      priority: fields[4] as int? ?? 1, // Default to medium priority
      subtasks: (fields[5] as List?)?.cast<Subtask>(),
      recurrenceType: fields[6] as int? ?? 0,
      lastRecurrence: fields[7] as DateTime?,
      isRecurring: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.isDone)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj._priority)
      ..writeByte(5)
      ..write(obj.subtasks)
      ..writeByte(6)
      ..write(obj.recurrenceType)
      ..writeByte(7)
      ..write(obj.lastRecurrence)
      ..writeByte(8)
      ..write(obj.isRecurring);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
