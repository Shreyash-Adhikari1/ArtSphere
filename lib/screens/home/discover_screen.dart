import 'package:artsphere/widgets/postcard_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {

  final List<Map<String, String>> dummyPosts = [
    {
      "username": "username321",
      "time": "8h ago",
      "image": "assets/images/dummy_image.png",
      "caption": "Learning :)",
    },
    {
      "username": "artlover22",
      "time": "5h ago",
      "image": "assets/images/dummy_image.png",
      "caption": "Productive day!",
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Text(
                "Trending Posts",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: dummyPosts.length,
              itemBuilder: (context, index) {
                final post = dummyPosts[index];
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: PostcardWidget(post:post)));
              },
            ),
          ),
        ],
      ),
    );
  }
}