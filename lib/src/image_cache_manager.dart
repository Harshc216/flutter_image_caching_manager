import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'models/cache_config.dart';
import 'services/disk_cache_service.dart';
import 'services/memory_cache_service.dart';

/// Manages image caching using memory, disk, and network layers.
///
/// Cache lookup order:
///
/// 1. Memory cache
/// 2. Disk cache
/// 3. Network
///
/// Newly downloaded images are stored in both disk and memory cache.
class ImageCacheManager {
  ImageCacheManager({
    CacheConfig config = const CacheConfig(),
    http.Client? httpClient,
  }) : _config = config,
       _httpClient = httpClient ?? http.Client(),
       _memoryCache = MemoryCacheService(maxSize: config.maxMemoryCacheSize),
       _diskCache = DiskCacheService(
         directoryName: config.cacheDirectoryName,
         cacheDuration: config.cacheDuration,
       );

  final CacheConfig _config;
  final http.Client _httpClient;

  final MemoryCacheService _memoryCache;
  final DiskCacheService _diskCache;

  /// Returns image bytes for [imageUrl].
  ///
  /// By default, the manager checks:
  ///
  /// Memory → Disk → Network
  ///
  /// Set [forceRefresh] to true to skip existing cache
  /// and download the image again.
  Future<Uint8List> getImage(
    String imageUrl, {
    bool forceRefresh = false,
  }) async {
    if (imageUrl.trim().isEmpty) {
      throw ArgumentError.value(
        imageUrl,
        'imageUrl',
        'Image URL cannot be empty.',
      );
    }

    final cacheKey = _generateCacheKey(imageUrl);

    if (!forceRefresh) {
      final memoryBytes = _memoryCache.get(cacheKey);

      if (memoryBytes != null) {
        return memoryBytes;
      }

      final diskBytes = await _diskCache.get(cacheKey);

      if (diskBytes != null) {
        _memoryCache.put(cacheKey, diskBytes);
        return diskBytes;
      }
    }

    final networkBytes = await _downloadImage(imageUrl);

    await _diskCache.put(cacheKey, networkBytes);

    _memoryCache.put(cacheKey, networkBytes);

    return networkBytes;
  }

  /// Removes an image from both memory and disk cache.
  Future<void> remove(String imageUrl) async {
    final cacheKey = _generateCacheKey(imageUrl);

    _memoryCache.remove(cacheKey);

    await _diskCache.remove(cacheKey);
  }

  /// Clears both memory and disk cache.
  Future<void> clearCache() async {
    _memoryCache.clear();

    await _diskCache.clear();
  }

  /// Removes only expired files from disk.
  ///
  /// Returns the number of removed files.
  Future<int> cleanExpiredCache() {
    return _diskCache.cleanExpired();
  }

  /// Returns the total disk cache size in bytes.
  Future<int> getCacheSize() {
    return _diskCache.getCacheSize();
  }

  /// Returns the number of images currently stored in memory.
  int get memoryCacheSize => _memoryCache.size;

  /// Generates a deterministic cache key from an image URL.
  String generateCacheKey(String imageUrl) {
    return _generateCacheKey(imageUrl);
  }

  /// Closes the underlying HTTP client.
  void dispose() {
    _httpClient.close();
  }

  Future<Uint8List> _downloadImage(String imageUrl) async {
    final uri = Uri.tryParse(imageUrl);

    if (uri == null || !uri.hasScheme) {
      throw FormatException('Invalid image URL: $imageUrl');
    }

    final response = await _httpClient.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ImageCacheException(
        'Failed to download image. '
        'HTTP status: ${response.statusCode}',
      );
    }

    if (response.bodyBytes.isEmpty) {
      throw const ImageCacheException('Downloaded image is empty.');
    }

    return Uint8List.fromList(response.bodyBytes);
  }

  String _generateCacheKey(String imageUrl) {
    return md5.convert(utf8.encode(imageUrl)).toString();
  }
}

/// Exception thrown when an image cannot be loaded.
class ImageCacheException implements Exception {
  const ImageCacheException(this.message);

  final String message;

  @override
  String toString() {
    return 'ImageCacheException: $message';
  }
}
