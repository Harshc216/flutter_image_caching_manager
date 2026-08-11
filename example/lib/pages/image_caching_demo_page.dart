import 'package:flutter/material.dart';
import 'package:flutter_image_caching_manager/flutter_image_caching_manager.dart';

import '../widgets/cache_controls.dart';
import '../widgets/cache_header.dart';
import '../widgets/cache_info_section.dart';
import '../widgets/image_grid_section.dart';

/// Main interactive demo page for Image Caching Manager.
class ImageCachingDemoPage extends StatefulWidget {
  const ImageCachingDemoPage({super.key});

  @override
  State<ImageCachingDemoPage> createState() => _ImageCachingDemoPageState();
}

class _ImageCachingDemoPageState extends State<ImageCachingDemoPage> {
  final ImageCacheManager _cacheManager = ImageCacheManager();

  final List<String> _imageUrls = List.generate(
    12,
    (index) => 'https://picsum.photos/500/400?random=${index + 1}',
  );

  bool _refreshing = false;
  int _cacheSize = 0;
  int _memoryCacheSize = 0;

  @override
  void initState() {
    super.initState();
    _updateCacheInfo();
  }

  @override
  void dispose() {
    _cacheManager.dispose();
    super.dispose();
  }

  Future<void> _updateCacheInfo() async {
    final size = await _cacheManager.getCacheSize();

    if (!mounted) return;

    setState(() {
      _cacheSize = size;
      _memoryCacheSize = _cacheManager.memoryCacheSize;
    });
  }

  Future<void> _refreshImages() async {
    setState(() {
      _refreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      _refreshing = false;
    });

    await _updateCacheInfo();
  }

  Future<void> _clearCache() async {
    await _cacheManager.clearCache();
    await _updateCacheInfo();

    if (!mounted) return;

    _showMessage('Image cache cleared');
  }

  Future<void> _cleanExpiredCache() async {
    final removed = await _cacheManager.cleanExpiredCache();
    await _updateCacheInfo();

    if (!mounted) return;

    _showMessage(
      '$removed expired cache file${removed == 1 ? '' : 's'} removed',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  String _formatCacheSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Image Caching Manager',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshImages,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshImages,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const CacheHeader(),
            const SizedBox(height: 16),
            CacheInfoSection(
              cacheSize: _cacheSize,
              memoryCacheSize: _memoryCacheSize,
              formattedCacheSize: _formatCacheSize(_cacheSize),
            ),
            const SizedBox(height: 16),
            CacheControls(
              onClearCache: _clearCache,
              onCleanExpiredCache: _cleanExpiredCache,
            ),
            const SizedBox(height: 20),
            ImageGridSection(
              imageUrls: _imageUrls,
              onForceRefresh: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }
}
