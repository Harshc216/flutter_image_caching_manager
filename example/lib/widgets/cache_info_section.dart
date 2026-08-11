import 'package:flutter/material.dart';

/// Section showing cache statistics for Disk Cache and Memory Cache.
class CacheInfoSection extends StatelessWidget {
  final int cacheSize;
  final int memoryCacheSize;
  final String formattedCacheSize;

  const CacheInfoSection({
    super.key,
    required this.cacheSize,
    required this.memoryCacheSize,
    required this.formattedCacheSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CacheInfoCard(
            icon: Icons.storage_rounded,
            title: 'Disk Cache',
            value: formattedCacheSize,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CacheInfoCard(
            icon: Icons.memory_rounded,
            title: 'Memory',
            value: '$memoryCacheSize images',
          ),
        ),
      ],
    );
  }
}

/// Reusable card displaying an icon, title, and string value.
class CacheInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const CacheInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.indigo,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
