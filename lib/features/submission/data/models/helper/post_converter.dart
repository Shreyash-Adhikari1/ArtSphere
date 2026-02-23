import 'package:artsphere/features/submission/data/models/submitted-post/submitted_post_api_model.dart';

class PostConverter {
  static SubmittedPostApiModel fromJson(dynamic value) {
    // populated object
    if (value is Map<String, dynamic>) {
      return SubmittedPostApiModel.fromJson(value);
    }

    // just an id
    if (value is String) {
      return SubmittedPostApiModel.fromId(value);
    }

    throw FormatException("Invalid submittedPostId type: ${value.runtimeType}");
  }

  /// For sending to backend, usually send the id.
  static dynamic toJson(SubmittedPostApiModel post) {
    return post.id;
  }
}
