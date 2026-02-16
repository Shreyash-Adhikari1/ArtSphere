import 'package:artsphere/features/post/data/models/post/post_author/post_author_api_model.dart';

/// This file is a helper module created for only one purpose
/// To tell dart if api response sends only author:_id
/// or the entire author object .i.e author:{_is,username,avatar}
/// we use this in the post api model while calling the author
/// this will make easier when handling create and get operations later dwn the line
class AuthorConverter {
  static PostAuthorApiModel? fromJson(dynamic value) {
    if (value == null) return null;

    // author is populated object
    if (value is Map<String, dynamic>) {
      return PostAuthorApiModel.fromJson(value);
    }

    // author is just an id string
    if (value is String) {
      return PostAuthorApiModel.fromId(value);
    }

    return null;
  }

  /// For sending to backend during create/edit, we usually only send the id.
  static dynamic toJson(PostAuthorApiModel? author) {
    return author?.id;
  }
}
