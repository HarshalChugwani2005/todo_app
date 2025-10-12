// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'virtual_pet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VirtualPetAdapter extends TypeAdapter<VirtualPet> {
  @override
  final int typeId = 2;

  @override
  VirtualPet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VirtualPet(
      name: fields[0] as String,
      petType: fields[1] as int,
      level: fields[2] as int,
      experience: fields[3] as int,
      health: fields[4] as int,
      happiness: fields[5] as int,
      hunger: fields[6] as int,
      energy: fields[7] as int,
      lastInteraction: fields[8] as DateTime?,
      createdAt: fields[9] as DateTime?,
      totalTasksCompleted: fields[10] as int,
      currentMood: fields[11] as int,
      growthStage: fields[12] as int,
      unlockedAccessories: (fields[13] as List?)?.cast<String>(),
      currentAccessory: fields[14] as String?,
      isAsleep: fields[15] as bool,
      lastFed: fields[16] as DateTime?,
      lastPlayed: fields[17] as DateTime?,
      primaryPersonalityTrait: fields[18] as int,
      secondaryPersonalityTrait: fields[19] as int,
      emotionHistory: (fields[20] as List?)?.cast<String>(),
      memoryHistory: (fields[21] as List?)?.cast<String>(),
      currentEmotion: fields[22] as int,
      emotionalIntensity: fields[23] as double,
      productivityStreak: fields[24] as int,
      lastEmotionChange: fields[25] as DateTime?,
      unlockedAchievements: (fields[26] as List?)?.cast<String>(),
      totalAchievementPoints: fields[27] as int,
      highPriorityTasksCompleted: fields[28] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VirtualPet obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.petType)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.experience)
      ..writeByte(4)
      ..write(obj.health)
      ..writeByte(5)
      ..write(obj.happiness)
      ..writeByte(6)
      ..write(obj.hunger)
      ..writeByte(7)
      ..write(obj.energy)
      ..writeByte(8)
      ..write(obj.lastInteraction)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.totalTasksCompleted)
      ..writeByte(11)
      ..write(obj.currentMood)
      ..writeByte(12)
      ..write(obj.growthStage)
      ..writeByte(13)
      ..write(obj.unlockedAccessories)
      ..writeByte(14)
      ..write(obj.currentAccessory)
      ..writeByte(15)
      ..write(obj.isAsleep)
      ..writeByte(16)
      ..write(obj.lastFed)
      ..writeByte(17)
      ..write(obj.lastPlayed)
      ..writeByte(18)
      ..write(obj.primaryPersonalityTrait)
      ..writeByte(19)
      ..write(obj.secondaryPersonalityTrait)
      ..writeByte(20)
      ..write(obj.emotionHistory)
      ..writeByte(21)
      ..write(obj.memoryHistory)
      ..writeByte(22)
      ..write(obj.currentEmotion)
      ..writeByte(23)
      ..write(obj.emotionalIntensity)
      ..writeByte(24)
      ..write(obj.productivityStreak)
      ..writeByte(25)
      ..write(obj.lastEmotionChange)
      ..writeByte(26)
      ..write(obj.unlockedAchievements)
      ..writeByte(27)
      ..write(obj.totalAchievementPoints)
      ..writeByte(28)
      ..write(obj.highPriorityTasksCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VirtualPetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
