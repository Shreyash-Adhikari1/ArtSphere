import 'package:artsphere/core/api/api_client.dart';
import 'package:artsphere/core/services/storage/token_service.dart';
import 'package:artsphere/features/comment/data/datasources/comment_datasource.dart';
import 'package:artsphere/features/comment/data/models/comment_api_model.dart';
import 'package:artsphere/features/comment/data/models/create/create_comment_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentRemoteDatasourceProvider = Provider<ICommentRemoteDatasource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return CommentRemoteDatasource(
    apiClient: apiClient,
    tokenservice: tokenService,
  );
});

class CommentRemoteDatasource implements ICommentRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;
  CommentRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenservice,
  }) : _apiClient = apiClient,
       _tokenService = tokenservice;
  @override
  Future<CommentApiModel> createComment(CreateCommentApiModel comment) {
    // TODO: implement createComment
    throw UnimplementedError();
  }

  @override
  Future<CommentApiModel> getCommentById(String commentId) {
    // TODO: implement getCommentById
    throw UnimplementedError();
  }

  @override
  Future<List<CommentApiModel>> getCommentsByUser(String userId) {
    // TODO: implement getCommentsByUser
    throw UnimplementedError();
  }

  @override
  Future<CommentApiModel> likeComment(String commentId, String userId) {
    // TODO: implement likeComment
    throw UnimplementedError();
  }

  @override
  Future<CommentApiModel> unlikeComment(String commentId, String userId) {
    // TODO: implement unlikeComment
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteComment(String commentId) {
    // TODO: implement deleteComment
    throw UnimplementedError();
  }
}
