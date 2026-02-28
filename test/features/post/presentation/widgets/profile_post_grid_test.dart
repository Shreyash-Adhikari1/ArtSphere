import 'package:artsphere/features/post/domain/entities/post_entity.dart';
import 'package:artsphere/features/post/presentation/widgets/profile_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapSliver(Widget sliver) {
  return MaterialApp(
    home: Scaffold(body: CustomScrollView(slivers: [sliver])),
  );
}

PostEntity _makePost({
  required String id,
  String? media,
  bool isChallengeSubmission = false,
}) {
  return PostEntity(
    postId: id,
    media: media,
    isChallengeSubmission: isChallengeSubmission,
  );
}

void main() {
  testWidgets('1) When loading=true shows CircularProgressIndicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapSliver(const ProfilePostGrid(posts: [], loading: true)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No posts yet'), findsNothing);
  });

  testWidgets('2) When loading=false and posts empty shows "No posts yet"', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapSliver(const ProfilePostGrid(posts: [], loading: false)),
    );

    expect(find.text('No posts yet'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    '3) When post.media is null/empty shows image_not_supported tile',
    (tester) async {
      final posts = [
        _makePost(id: 'p1', media: null),
        _makePost(id: 'p2', media: ''),
        _makePost(id: 'p3', media: '   '),
      ];

      await tester.pumpWidget(
        _wrapSliver(ProfilePostGrid(posts: posts, loading: false)),
      );

      // Each invalid media -> fallback tile with icon
      expect(find.byIcon(Icons.image_not_supported), findsNWidgets(3));
    },
  );

  testWidgets('4) With valid media renders Image.network for each post', (
    tester,
  ) async {
    final posts = [
      _makePost(id: 'p1', media: 'https://example.com/a.jpg'),
      _makePost(id: 'p2', media: 'https://example.com/b.jpg'),
    ];

    await tester.pumpWidget(
      _wrapSliver(ProfilePostGrid(posts: posts, loading: false)),
    );

    // Image.network creates Image widgets
    expect(find.byType(Image), findsNWidgets(2));
  });

  testWidgets('5) Tapping a grid item calls onTapPost with correct post', (
    tester,
  ) async {
    final posts = [
      _makePost(id: 'p1', media: 'https://example.com/a.jpg'),
      _makePost(id: 'p2', media: 'https://example.com/b.jpg'),
    ];

    PostEntity? tapped;

    await tester.pumpWidget(
      _wrapSliver(
        ProfilePostGrid(
          posts: posts,
          loading: false,
          onTapPost: (p) => tapped = p,
        ),
      ),
    );

    // Tap first InkWell
    final firstTile = find.byType(InkWell).first;

    await tester.ensureVisible(firstTile);
    await tester.tap(firstTile);
    await tester.pump();

    expect(tapped?.postId, 'p1');
  });
}
