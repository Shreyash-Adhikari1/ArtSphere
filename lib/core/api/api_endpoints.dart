import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  static const bool isPhysicalDevice = false;
  static const String _ipAddress = '192.168.68.103';
  static const int _port = 5000;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api';
  static String get mediaServerUrl => serverUrl;

  static String get profileImages => '$mediaServerUrl/uploads/profile-image';
  static String get postImages => '$mediaServerUrl/uploads/post-images';
  static String get challengeImages =>
      '$mediaServerUrl/uploads/challenge-images';
  static String get challengeSubmissions =>
      '$mediaServerUrl/uploads/challenge-submissions';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ User Endpoints =============
  static const String users = '/user';
  static const String userLogin = '/user/login';
  static const String userRegister = '/user/register';
  static String userById(String id) => '/user/$id';
  static const String getProfile = '/user/me';
  static const String editProfile = '/user/me';

  // ============= Post Endpoints =============
  static const String posts = '/post';
  static const String createPost = '/post/create';
  static String editPost(String id) => '/post/edit/$id';
  static const String getFeed = '/post/posts';
  static const String getMyPosts = '/post/posts/my-posts';
  static const String getFollowingFeed = '/post/posts/following';
  static String getPostsByUser(String id) => '/post/user/$id';
  static String deletePost(String id) => '/post/delete/$id';
  static String likePost(String id) => '/post/like/$id';
  static String unlikePost(String id) => '/post/unlike/$id';

  // ============== Comment Endpoints ==============
  static const String comments = '/comment';
  static String createComment(String id) => 'comment/create/$id';
  static String deleteComment(String id) => 'comment/delete/$id';
  static String likeComment(String id) => 'comment/like/$id';
  static String unlikeComment(String id) => 'comment/unlike/$id';

  // ============ Batch Endpoints ============
  static const String batches = '/batches';
  static String batchById(String id) => '/batches/$id';

  // ============ Category Endpoints ============
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Student Endpoints ============
  static const String students = '/students';
  static const String studentLogin = '/students/login';
  static const String studentRegister = '/students/register';
  static String studentById(String id) => '/students/$id';
  static String studentPhoto(String id) => '/students/$id/photo';

  // ============ Item Endpoints ============
  static const String items = '/items';
  static String itemById(String id) => '/items/$id';
  static String itemClaim(String id) => '/items/$id/claim';
}
