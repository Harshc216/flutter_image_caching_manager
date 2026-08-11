import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Handles persistent image storage on the device.
class DiskCacheService {
  DiskCacheService({
    required this.directoryName,
    required this.cacheDuration,
  });

  /// Name of the directory used to store cached images.
  final String directoryName;

  /// Duration after which a cached file is considered expired.
  final Duration cacheDuration;

  Directory? _cacheDirectory;

  /// Returns the cache directory, creating it if necessary.
  Future<Directory> _getCacheDirectory() async {
    if (_cacheDirectory != null) {
      return _cacheDirectory!;
    }

    final baseDirectory = await getTemporaryDirectory();

    final directory = Directory(
      '${baseDirectory.path}/$directoryName',
    );

    if (!await directory.exists()) {
      await directory.create(
        recursive: true,
      );
    }

    _cacheDirectory = directory;

    return directory;
  }

  /// Returns the file associated with [key].
  Future<File> _getFile(String key) async {
    final directory = await _getCacheDirectory();

    return File(
      '${directory.path}/$key.cache',
    );
  }

  /// Stores [bytes] on disk using [key].
  Future<void> put(
      String key,
      Uint8List bytes,
      ) async {
    final file = await _getFile(key);

    await file.writeAsBytes(
      bytes,
      flush: true,
    );
  }

  /// Returns cached bytes if the file exists and has not expired.
  ///
  /// Returns null when:
  /// - the file doesn't exist
  /// - the file has expired
  /// - the file cannot be read
  Future<Uint8List?> get(String key) async {
    try {
      final file = await _getFile(key);

      if (!await file.exists()) {
        return null;
      }

      final isExpired = await _isExpired(file);

      if (isExpired) {
        await _deleteFileSafely(file);
        return null;
      }

      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// Checks whether a cached file exists and is still valid.
  Future<bool> contains(String key) async {
    try {
      final file = await _getFile(key);

      if (!await file.exists()) {
        return false;
      }

      if (await _isExpired(file)) {
        await _deleteFileSafely(file);
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Removes a single cached image.
  Future<void> remove(String key) async {
    try {
      final file = await _getFile(key);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore file deletion errors.
    }
  }

  /// Removes all cached images.
  Future<void> clear() async {
    try {
      final directory = await _getCacheDirectory();

      if (await directory.exists()) {
        await directory.delete(
          recursive: true,
        );
      }

      _cacheDirectory = null;
    } catch (_) {
      // Ignore cache deletion errors.
    }
  }

  /// Removes only expired files.
  ///
  /// Returns the number of deleted files.
  Future<int> cleanExpired() async {
    var deletedCount = 0;

    try {
      final directory = await _getCacheDirectory();

      if (!await directory.exists()) {
        return 0;
      }

      await for (final entity in directory.list()) {
        if (entity is! File) {
          continue;
        }

        if (!entity.path.endsWith('.cache')) {
          continue;
        }

        if (await _isExpired(entity)) {
          await _deleteFileSafely(entity);
          deletedCount++;
        }
      }
    } catch (_) {
      // Ignore cache cleanup errors.
    }

    return deletedCount;
  }

  /// Calculates the total size of the disk cache in bytes.
  Future<int> getCacheSize() async {
    var totalSize = 0;

    try {
      final directory = await _getCacheDirectory();

      if (!await directory.exists()) {
        return 0;
      }

      await for (final entity in directory.list()) {
        if (entity is! File) {
          continue;
        }

        if (!entity.path.endsWith('.cache')) {
          continue;
        }

        try {
          totalSize += await entity.length();
        } catch (_) {
          // Ignore individual file errors.
        }
      }
    } catch (_) {
      // Ignore cache size errors.
    }

    return totalSize;
  }

  /// Checks whether [file] has exceeded [cacheDuration].
  Future<bool> _isExpired(File file) async {
    final lastModified = await file.lastModified();
    final age = DateTime.now().difference(lastModified);

    return age >= cacheDuration;
  }

  Future<void> _deleteFileSafely(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignore deletion errors.
    }
  }
}