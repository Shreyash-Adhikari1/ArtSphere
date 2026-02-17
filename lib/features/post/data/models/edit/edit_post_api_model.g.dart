// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_post_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditPostApiModel _$EditPostApiModelFromJson(Map<String, dynamic> json) =>
    EditPostApiModel(
      caption: json['caption'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      visibility: json['visibility'] as String?,
    );

Map<String, dynamic> _$EditPostApiModelToJson(EditPostApiModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('caption', instance.caption);
  writeNotNull('tags', instance.tags);
  writeNotNull('visibility', instance.visibility);
  return val;
}
