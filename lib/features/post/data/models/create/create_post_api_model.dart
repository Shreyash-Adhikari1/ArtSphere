import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post_api_model.g.dart';

@JsonSerializable()
class CreatePostApiModel {
  final String? caption;
  final String? mediaType;
  final List<String>? tags;
  final String? visibility;
  const CreatePostApiModel({
    this.caption,
    this.mediaType,
    this.tags,
    this.visibility,
  });

  factory CreatePostApiModel.fromJson(Map<String, dynamic> json) =>
      _$CreatePostApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostApiModelToJson(this);
}
