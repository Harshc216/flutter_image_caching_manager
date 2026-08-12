import 'package:flutter/material.dart';
import 'package:flutter_image_caching_manager/flutter_image_caching_manager.dart';

/// Grid display section showing cached images.
class ImageGridSection extends StatelessWidget {
  final ImageCacheManager cacheManager;
  final List<String> imageUrls;
  final VoidCallback onForceRefresh;

  const ImageGridSection({
    super.key,
    required this.cacheManager,
    required this.imageUrls,
    required this.onForceRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cached Images',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: imageUrls.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            return ImageCard(
              cacheManager: cacheManager,
              imageUrl: imageUrls[index],
              index: index,
              onForceRefresh: onForceRefresh,
            );
          },
        ),
      ],
    );
  }
}

/// Card representing an individual cached image.
class ImageCard extends StatelessWidget {
  final ImageCacheManager cacheManager;
  final String imageUrl;
  final int index;
  final VoidCallback onForceRefresh;

  const ImageCard({
    super.key,
    required this.cacheManager,
    required this.imageUrl,
    required this.index,
    required this.onForceRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: CachedImage(
              cacheManager: cacheManager,
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              placeholder: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              errorWidget: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 36,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Image ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Force refresh',
                  onPressed: onForceRefresh,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
