import 'dart:typed_data';

/// In-memory cache for downloaded image bytes.
class MemoryCacheService {
  MemoryCacheService({required this.maxSize});

  /// Maximum number of images that can be stored.
  final int maxSize;

  final Map<String, Uint8List> _cache = <String, Uint8List>{};

  /// Returns cached image bytes for [key], if available.
  Uint8List? get(String key) {
    final bytes = _cache.remove(key);

    if (bytes == null) {
      return null;
    }

    // Reinsert to mark this item as recently used.
    _cache[key] = bytes;

    return bytes;
  }

  /// Stores image [bytes] using [key].
  ///
  /// If the cache exceeds [maxSize], the least recently used
  /// item is removed.
  void put(String key, Uint8List bytes) {
    _cache.remove(key);
    _cache[key] = bytes;

    while (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Removes a single cached image.
  bool remove(String key) {
    return _cache.remove(key) != null;
  }

  /// Removes all cached images.
  void clear() {
    _cache.clear();
  }

  /// Returns the number of images currently cached in memory.
  int get size => _cache.length;

  /// Returns whether [key] exists in memory cache.
  bool contains(String key) {
    return _cache.containsKey(key);
  }
}
