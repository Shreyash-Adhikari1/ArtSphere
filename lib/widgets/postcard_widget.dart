import 'package:flutter/material.dart';

class PostcardWidget extends StatelessWidget {
  const PostcardWidget({
    super.key,
    required this.post,
  });

  final Map<String, String> post;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6ED),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "@${post['username']}   Posted - ${post['time']}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              post['image']!,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            post['caption']!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.favorite_border,
                  size: 28, color: Color(0xFFC974A6)),
              Icon(Icons.send_outlined, size: 26),
              Icon(Icons.bookmark_border, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}
