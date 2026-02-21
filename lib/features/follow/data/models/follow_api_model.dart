import 'package:artsphere/features/follow/data/models/follow-user/follow_user_api_model.dart';
import 'package:artsphere/features/follow/data/models/helper/user_converter.dart';
import 'package:artsphere/features/follow/domain/entities/follow_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_api_model.g.dart';

@JsonSerializable()
class FollowApiModel {
  @JsonKey(name: "_id")
  final String? followId;
  @JsonKey(
    fromJson: FollowUserConverter.fromJson,
    toJson: FollowUserConverter.toJson,
  )
  final FollowUserApiModel? follower;

  @JsonKey(
    fromJson: FollowUserConverter.fromJson,
    toJson: FollowUserConverter.toJson,
  )
  final FollowUserApiModel? following;

  final bool? isFollowActive;
  final bool? isFollowedByMe;
  final DateTime? createdAt;

  const FollowApiModel({
    this.followId,
    this.follower,
    this.following,
    this.isFollowActive,
    this.isFollowedByMe,
    this.createdAt,
  });

  // from Json
  factory FollowApiModel.fromJson(Map<String, dynamic> json) =>
      _$FollowApiModelFromJson(json);
  // to Json
  Map<String, dynamic> toJson() => _$FollowApiModelToJson(this);

  // to entity
  FollowEntity toEntity() {
    return FollowEntity(
      followId: followId,
      follower: follower?.toEntity(),
      following: following?.toEntity(),
      isFollowActive: isFollowActive,
      isFollowedByMe: isFollowedByMe,
      createdAt: createdAt,
    );
  }

  // from entity
  factory FollowApiModel.fromEntity(FollowEntity follow) {
    return FollowApiModel(
      followId: follow.followId,
      follower: follow.follower == null
          ? null
          : FollowUserApiModel(
              id: follow.follower!.userId,
              username: follow.follower!.username,
              avatar: follow.follower!.avatar,
            ),
      following: follow.following == null
          ? null
          : FollowUserApiModel(
              id: follow.following!.userId,
              username: follow.following!.username,
              avatar: follow.following!.avatar,
            ),
      isFollowActive: follow.isFollowActive,
      isFollowedByMe: follow.isFollowedByMe,
      createdAt: follow.createdAt,
    );
  }

  // to entity lisst
  static List<FollowEntity> toEntityList(List<FollowApiModel> model) {
    return model.map((model) => model.toEntity()).toList();
  }
}
