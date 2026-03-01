// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostHiveModelAdapter extends TypeAdapter<PostHiveModel> {
  @override
  final typeId = 1;

  @override
  PostHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostHiveModel(
      postId: fields[0] as String,
      authorId: fields[1] as String?,
      authorUsername: fields[2] as String?,
      authorAvatar: fields[3] as String?,
      media: fields[4] as String?,
      mediaType: fields[5] as String?,
      caption: fields[6] as String?,
      tags: (fields[7] as List?)?.cast<String>(),
      visibility: fields[8] as String?,
      likeCount: (fields[9] as num?)?.toInt(),
      likedBy: (fields[10] as List?)?.cast<String>(),
      commentCount: (fields[11] as num?)?.toInt(),
      commentedBy: (fields[12] as List?)?.cast<String>(),
      isChallengeSubmission: fields[13] as bool?,
      createdAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PostHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.postId)
      ..writeByte(1)
      ..write(obj.authorId)
      ..writeByte(2)
      ..write(obj.authorUsername)
      ..writeByte(3)
      ..write(obj.authorAvatar)
      ..writeByte(4)
      ..write(obj.media)
      ..writeByte(5)
      ..write(obj.mediaType)
      ..writeByte(6)
      ..write(obj.caption)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.visibility)
      ..writeByte(9)
      ..write(obj.likeCount)
      ..writeByte(10)
      ..write(obj.likedBy)
      ..writeByte(11)
      ..write(obj.commentCount)
      ..writeByte(12)
      ..write(obj.commentedBy)
      ..writeByte(13)
      ..write(obj.isChallengeSubmission)
      ..writeByte(14)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
