/// Configuration for the image caching manager.
///
/// This class controls how images are stored and when
/// cached images should be considered expired.
class CacheConfig {
  /// Creates a cache configuration.
  const CacheConfig({
    this.maxMemoryCacheSize = 50,
    this.cacheDuration = const Duration(days: 7),
    this.cacheDirectoryName = 'flutter_image_caching_manager',
  }) : assert(
         maxMemoryCacheSize > 0,
         'maxMemoryCacheSize must be greater than 0.',
       ),
       assert(cacheDirectoryName != '', 'cacheDirectoryName cannot be empty.');

  /// Maximum number of images kept in memory.
  ///
  /// This is a count of cached images, not bytes.
  final int maxMemoryCacheSize;

  /// How long a disk-cached image remains valid.
  ///
  /// The default duration is 7 days.
  final Duration cacheDuration;

  /// Name of the directory used for disk caching.
  final String cacheDirectoryName;

  /// Creates a copy with selected values changed.
  CacheConfig copyWith({
    int? maxMemoryCacheSize,
    Duration? cacheDuration,
    String? cacheDirectoryName,
  }) {
    return CacheConfig(
      maxMemoryCacheSize: maxMemoryCacheSize ?? this.maxMemoryCacheSize,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      cacheDirectoryName: cacheDirectoryName ?? this.cacheDirectoryName,
    );
  }

  @override
  String toString() {
    return 'CacheConfig('
        'maxMemoryCacheSize: $maxMemoryCacheSize, '
        'cacheDuration: $cacheDuration, '
        'cacheDirectoryName: $cacheDirectoryName'
        ')';
  }
}
