// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeHiveModelAdapter extends TypeAdapter<ChallengeHiveModel> {
  @override
  final typeId = 2;

  @override
  ChallengeHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeHiveModel(
      challengeId: fields[0] as String,
      challengeTitle: fields[1] as String?,
      challengeDescription: fields[2] as String?,
      challengeMedia: fields[3] as String?,
      endsAt: fields[4] as DateTime?,
      submissionCount: (fields[5] as num?)?.toInt(),
      challengerId: fields[6] as String?,
      challengerUsername: fields[7] as String?,
      challengerAvatar: fields[8] as String?,
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.challengeId)
      ..writeByte(1)
      ..write(obj.challengeTitle)
      ..writeByte(2)
      ..write(obj.challengeDescription)
      ..writeByte(3)
      ..write(obj.challengeMedia)
      ..writeByte(4)
      ..write(obj.endsAt)
      ..writeByte(5)
      ..write(obj.submissionCount)
      ..writeByte(6)
      ..write(obj.challengerId)
      ..writeByte(7)
      ..write(obj.challengerUsername)
      ..writeByte(8)
      ..write(obj.challengerAvatar)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
