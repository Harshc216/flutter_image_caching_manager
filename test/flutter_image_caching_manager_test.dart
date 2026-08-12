import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_image_caching_manager/flutter_image_caching_manager.dart';

void main() {
  group('CacheConfig', () {
    test('uses default values', () {
      const config = CacheConfig();

      expect(config.maxMemoryCacheSize, 50);
      expect(
        config.cacheDuration,
        const Duration(days: 7),
      );
      expect(
        config.cacheDirectoryName,
        'flutter_image_caching_manager',
      );
    });

    test('copyWith updates selected values', () {
      const config = CacheConfig();

      final updated = config.copyWith(
        maxMemoryCacheSize: 100,
        cacheDuration: const Duration(days: 3),
      );

      expect(updated.maxMemoryCacheSize, 100);
      expect(
        updated.cacheDuration,
        const Duration(days: 3),
      );

      expect(
        updated.cacheDirectoryName,
        config.cacheDirectoryName,
      );
    });

    test('toString contains configuration values', () {
      const config = CacheConfig(
        maxMemoryCacheSize: 25,
        cacheDuration: Duration(days: 2),
        cacheDirectoryName: 'test_cache',
      );

      final result = config.toString();

      expect(result, contains('25'));
      expect(result, contains('48:00:00'));
      expect(result, contains('test_cache'));
    });
  });

  group('ImageCacheManager', () {
    late ImageCacheManager manager;

    setUp(() {
      manager = ImageCacheManager(
        config: const CacheConfig(
          maxMemoryCacheSize: 5,
          cacheDuration: Duration(days: 7),
        ),
      );
    });

    tearDown(() async {
      await manager.clearCache();
      manager.dispose();
    });

    test('generates deterministic cache keys', () {
      const url =
          'https://picsum.photos/400/300?random=1';

      final firstKey = manager.generateCacheKey(url);
      final secondKey = manager.generateCacheKey(url);

      expect(firstKey, equals(secondKey));
      expect(firstKey, isNotEmpty);
    });

    test('different URLs generate different cache keys', () {
      final firstKey = manager.generateCacheKey(
        'https://picsum.photos/400/300?random=1',
      );

      final secondKey = manager.generateCacheKey(
        'https://picsum.photos/400/300?random=2',
      );

      expect(firstKey, isNot(equals(secondKey)));
    });

    test('initial memory cache size is zero', () {
      expect(manager.memoryCacheSize, 0);
    });

    test('throws ArgumentError for empty image URL', () async {
      expect(
            () => manager.getImage(''),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for whitespace image URL', () async {
      expect(
            () => manager.getImage('   '),
        throwsArgumentError,
      );
    });

    test('clearCache clears memory cache', () async {
      expect(manager.memoryCacheSize, 0);

      await manager.clearCache();

      expect(manager.memoryCacheSize, 0);
    });

    test('generateCacheKey returns an MD5-length key', () {
      final key = manager.generateCacheKey(
        'https://example.com/image.png',
      );

      expect(key.length, 32);
    });

    test('cleanExpiredCache returns zero when no cache files are expired', () async {
      final count = await manager.cleanExpiredCache();
      expect(count, equals(0));
    });
  });

  group('CachedImage widget', () {
    testWidgets(
      'can be created with required image URL',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CachedImage(
              imageUrl: 'https://example.com/image.png',
            ),
          ),
        );

        expect(find.byType(CachedImage), findsOneWidget);
      },
    );

    testWidgets(
      'shows custom placeholder while loading',
          (tester) async {
        const placeholder = Text('Loading image');

        await tester.pumpWidget(
          const MaterialApp(
            home: CachedImage(
              imageUrl: 'https://example.com/image.png',
              placeholder: placeholder,
            ),
          ),
        );

        expect(find.text('Loading image'), findsOneWidget);
      },
    );

    testWidgets(
      'supports custom error widget',
          (tester) async {
        const errorWidget = Text('Image failed');

        await tester.pumpWidget(
          const MaterialApp(
            home: CachedImage(
              imageUrl: 'https://example.com/image.png',
              errorWidget: errorWidget,
            ),
          ),
        );

        expect(find.byType(CachedImage), findsOneWidget);
      },
    );

    testWidgets(
      'supports width and height',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CachedImage(
              imageUrl: 'https://example.com/image.png',
              width: 200,
              height: 150,
            ),
          ),
        );

        final widget = tester.widget<CachedImage>(
          find.byType(CachedImage),
        );

        expect(widget.width, 200);
        expect(widget.height, 150);
      },
    );

    testWidgets(
      'supports force refresh',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CachedImage(
              imageUrl: 'https://example.com/image.png',
              forceRefresh: true,
            ),
          ),
        );

        final widget = tester.widget<CachedImage>(
          find.byType(CachedImage),
        );

        expect(widget.forceRefresh, isTrue);
      },
    );
  });
}