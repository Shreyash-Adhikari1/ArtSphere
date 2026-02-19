import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_comment_api_model.g.dart';

@JsonSerializable()
class CreateCommentApiModel {
  final String commentText;
  const CreateCommentApiModel({required this.commentText});

  factory CreateCommentApiModel.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCommentApiModelToJson(this);
}
