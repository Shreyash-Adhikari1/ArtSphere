import 'package:artsphere/features/comment/data/models/comment-user/comment_user_api_model.dart';

class CommentUserConverter {
  static CommentUserApiModel? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      return CommentUserApiModel.fromJson(json);
    }

    if (json is String) {
      return CommentUserApiModel.fromId(json);
    }
    return null;
  }

  static dynamic toJson(CommentUserApiModel? model) {
    if (model == null) return null;
    if (model.username == null && model.avatar == null && model.id != null) {
      return model.id;
    }
    return model.toJson();
  }
}
