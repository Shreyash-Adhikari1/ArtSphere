import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_post_api_model.g.dart';

@JsonSerializable(includeIfNull: false)
class EditPostApiModel {
  final String? caption;
  final List<String>? tags;
  final String? visibility;

  EditPostApiModel({this.caption, this.tags, this.visibility});

  factory EditPostApiModel.fromJson(Map<String, dynamic> json) =>
      _$EditPostApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$EditPostApiModelToJson(this);
}
