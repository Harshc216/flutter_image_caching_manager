# flutter_image_caching_manager

[![Flutter Version](https://img.shields.io/badge/Flutter-%3E%3D1.17.0-blue.svg)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%3E%3D3.11.4-blue.svg)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-orange.svg)](#)

**flutter_image_caching_manager** is a high-performance, multi-tiered (Memory → Disk → Network) image caching library for Flutter applications. Designed for smooth, responsive user interfaces, it features automatic Least-Recently-Used (LRU) memory management, persistent disk storage, configurable expiration TTLs, seamless `CachedImage` UI widgets with fade-in transitions, and granular cache maintenance APIs.

---

## 📷 Architecture Overview

```
                      +------------------+
                      |   CachedImage    |
                      |   UI Widget      |
                      +--------+---------+
                               |
                               v
                     +-------------------+
                     | ImageCacheManager |
                     +---------+---------+
                               |
            +------------------+------------------+
            | 1. Memory Check  |                  |
            v                  v                  v
    +---------------+  +---------------+  +---------------+
    | Memory Cache  |  |  Disk Cache   |  | Network Client|
    |  (LRU Cache)  |  | (Storage/TTL) |  |   (HTTP GET)  |
    +---------------+  +---------------+  +---------------+
```

*Fast 3-tier lookup order guarantees instant rendering from memory on repeated views, offline availability from persistent disk, and fallback to network fetching.*

---

## ✨ Features

- **⚡ Multi-Tier Caching Architecture**
  - Instantaneous retrieval with **Memory Cache** using an LRU (Least-Recently-Used) eviction policy.
  - Persistent **Disk Storage** with MD5 url-hashing and automated file age checks.
  - Asynchronous **Network Client** with status validation and error safety.
- **🖼️ High-Fidelity `CachedImage` Widget**
  - Easy drop-in replacement for standard image widgets.
  - Smooth animated fade-in transitions (`fadeInDuration`).
  - Support for `width`, `height`, `BoxFit`, `Alignment`, and `BorderRadius` clipping.
  - Built-in fallback placeholders and error widgets with full custom override support.
- **⏱️ Configurable Expiration & Expiry TTL**
  - Define custom disk cache validity durations (e.g., 7 days, 1 hour, etc.).
  - Automatic expiration check on cache reads with single-command manual cleanup (`cleanExpiredCache()`).
- **🧹 Storage Management & Metrics**
  - Calculate total occupied disk space with `getCacheSize()`.
  - Monitor live active memory cache count with `memoryCacheSize`.
  - Clear full cache or purge specific image URLs on demand.
- **🔌 Dependency Injection Friendly**
  - Inject custom `http.Client` instances for enterprise authentication, request headers, or mock testing.

---

## 📦 Installation

Add **flutter_image_caching_manager** to your project's `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # From pub.dev
  flutter_image_caching_manager: ^0.0.1
```

Or reference it directly from a Git repository:

```yaml
dependencies:
  flutter_image_caching_manager:
    git:
      url: https://github.com/your_username/flutter_image_caching_manager.git
      ref: main
```

Run the get command:

```bash
flutter pub get
```

---

## 🚀 Usage

Import the library in your Dart code:

```dart
import 'package:flutter_image_caching_manager/flutter_image_caching_manager.dart';
```

### 1. Basic Image Loading
Render a network image with automatic multi-tiered caching and a default progress indicator.

```dart
CachedImage(
  imageUrl: 'https://picsum.photos/500/400?random=1',
  width: 300,
  height: 200,
)
```

### 2. Styling with Border Radius & Fade-in Duration
Apply rounded corners using `BorderRadius` and control the visual fade-in transition duration when the image finishes loading.

```dart
CachedImage(
  imageUrl: 'https://picsum.photos/500/400?random=2',
  width: 250,
  height: 250,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(16.0),
  fadeInDuration: const Duration(milliseconds: 400),
)
```

### 3. Custom Placeholder & Error Widgets
Provide custom loading spinners, skeleton shimmer components, or custom fallback failure UI widgets.

```dart
CachedImage(
  imageUrl: 'https://picsum.photos/500/400?random=3',
  width: 200,
  height: 200,
  placeholder: const Center(
    child: CircularProgressIndicator(
      color: Colors.indigo,
      strokeWidth: 3,
    ),
  ),
  errorWidget: Container(
    color: Colors.red.shade50,
    child: const Center(
      child: Icon(Icons.broken_image, color: Colors.red, size: 36),
    ),
  ),
)
```

### 4. Force Refresh Image
Bypass both memory and disk cache to force download the latest version from the network.

```dart
CachedImage(
  imageUrl: 'https://picsum.photos/500/400?random=4',
  forceRefresh: true,
)
```

### 5. Custom Cache Configuration
Initialize a custom `ImageCacheManager` instance with specific memory capacity, disk cache duration (TTL), and storage folder names.

```dart
final customCacheManager = ImageCacheManager(
  config: const CacheConfig(
    maxMemoryCacheSize: 100, // Store up to 100 images in memory
    cacheDuration: Duration(days: 14), // Cache files on disk for 14 days
    cacheDirectoryName: 'my_app_image_cache',
  ),
);

// Pass custom cacheManager into CachedImage
CachedImage(
  imageUrl: 'https://picsum.photos/500/400?random=5',
  cacheManager: customCacheManager,
)
```

### 6. Programmatic Cache Maintenance APIs
Directly interact with `ImageCacheManager` to manage cached assets, monitor disk usage, and execute cleanup tasks.

```dart
final cacheManager = ImageCacheManager();

// 1. Fetch raw image bytes
Uint8List bytes = await cacheManager.getImage('https://example.com/avatar.png');

// 2. Query total disk cache size (in bytes)
int totalBytes = await cacheManager.getCacheSize();
print('Cache Size: ${(totalBytes / 1024 / 1024).toStringAsFixed(2)} MB');

// 3. Query count of images in active memory cache
int activeMemoryCount = cacheManager.memoryCacheSize;

// 4. Remove expired cache files
int purgedCount = await cacheManager.cleanExpiredCache();
print('Removed $purgedCount expired cache files.');

// 5. Remove a specific cached image
await cacheManager.remove('https://example.com/avatar.png');

// 6. Clear entire memory and disk cache
await cacheManager.clearCache();
```

---

## 🛠️ API Reference

### `CachedImage` Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `imageUrl` | `String` | **required** | The URL of the image to load. |
| `width` | `double?` | `null` | Target width constraint for the widget. |
| `height` | `double?` | `null` | Target height constraint for the widget. |
| `fit` | `BoxFit` | `BoxFit.cover` | Defines how the image scales to fit its bounds. |
| `alignment` | `Alignment` | `Alignment.center` | Alignment of the image inside its container. |
| `borderRadius` | `BorderRadius?` | `null` | Border radius for clipping the image. |
| `placeholder` | `Widget?` | `null` | Custom widget displayed while the image is loading. |
| `errorWidget` | `Widget?` | `null` | Custom widget displayed when image fetch fails. |
| `forceRefresh` | `bool` | `false` | When true, skips cache and forces fresh download. |
| `cacheManager` | `ImageCacheManager?` | `null` | Custom cache manager instance. Uses global default if `null`. |
| `fadeInDuration` | `Duration` | `250ms` | Duration of the fade-in animation upon image render. |

### `CacheConfig` Properties

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `maxMemoryCacheSize` | `int` | `50` | Maximum number of images retained in LRU memory cache. |
| `cacheDuration` | `Duration` | `7 days` | Duration after which disk-cached images are considered expired. |
| `cacheDirectoryName` | `String` | `'flutter_image_caching_manager'` | Subfolder name within temporary storage for cached files. |

### `ImageCacheManager` Methods & Properties

| Method / Property | Return Type | Description |
| :--- | :--- | :--- |
| `getImage(url, {forceRefresh})` | `Future<Uint8List>` | Retrieves image bytes via Memory → Disk → Network pipeline. |
| `remove(imageUrl)` | `Future<void>` | Removes a specific image URL from both memory and disk cache. |
| `clearCache()` | `Future<void>` | Flushes all entries from memory cache and deletes all disk cache files. |
| `cleanExpiredCache()` | `Future<int>` | Deletes expired disk files based on `cacheDuration`. Returns count of files deleted. |
| `getCacheSize()` | `Future<int>` | Calculates the total size of all cached disk files in bytes. |
| `memoryCacheSize` | `int` | Property returning the current number of items cached in memory. |
| `generateCacheKey(imageUrl)`| `String` | Utility generating deterministic MD5 key for a given URL string. |
| `dispose()` | `void` | Closes the underlying HTTP client. |

---

## 📄 License

```lic
MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

