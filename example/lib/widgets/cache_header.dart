import 'package:flutter/material.dart';

/// Header banner displaying the title and description of smart image caching.
class CacheHeader extends StatelessWidget {
  const CacheHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.image_rounded,
            size: 42,
            color: Colors.white,
          ),
          SizedBox(height: 14),
          Text(
            'Smart Image Caching',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Memory + disk caching with expiration and cache management.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
