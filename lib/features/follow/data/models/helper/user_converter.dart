import 'package:artsphere/features/follow/data/models/follow-user/follow_user_api_model.dart';

class FollowUserConverter {
  static FollowUserApiModel? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      return FollowUserApiModel.fromJson(json);
    }

    if (json is String) {
      return FollowUserApiModel.fromId(json);
    }
    return null;
  }

  static dynamic toJson(FollowUserApiModel? model) {
    if (model == null) return null;
    if (model.username == null && model.avatar == null && model.id != null) {
      return model.id;
    }
    return model.toJson();
  }
}
