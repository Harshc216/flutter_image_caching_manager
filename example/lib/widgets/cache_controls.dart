import 'package:flutter/material.dart';

/// Control buttons for clearing and cleaning the cache.
class CacheControls extends StatelessWidget {
  final VoidCallback onClearCache;
  final VoidCallback onCleanExpiredCache;

  const CacheControls({
    super.key,
    required this.onClearCache,
    required this.onCleanExpiredCache,
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
          const Text(
            'Cache Controls',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClearCache,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                  ),
                  label: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCleanExpiredCache,
                  icon: const Icon(
                    Icons.cleaning_services_outlined,
                  ),
                  label: const Text('Clean'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
