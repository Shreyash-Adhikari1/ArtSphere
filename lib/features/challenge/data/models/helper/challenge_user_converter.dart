import 'package:artsphere/features/challenge/data/models/helper/challenge_user_api_model.dart';

class ChallengeUserConverter {
  static ChallengeUserApiModel? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      return ChallengeUserApiModel.fromJson(json);
    }

    if (json is String) {
      return ChallengeUserApiModel.fromId(json);
    }
    return null;
  }

  static dynamic toJson(ChallengeUserApiModel? model) {
    if (model == null) return null;
    if (model.username == null && model.avatar == null && model.id != null) {
      return model.id;
    }
    return model.toJson();
  }
}
