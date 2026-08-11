import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../image_cache_manager.dart';

/// A reusable image widget that loads images through [ImageCacheManager].
///
/// The image loading order is:
///
/// Memory cache → Disk cache → Network
///
/// Use [forceRefresh] to bypass existing cache data.
class CachedImage extends StatefulWidget {
  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.forceRefresh = false,
    this.cacheManager,
    this.fadeInDuration = const Duration(milliseconds: 250),
  });

  /// URL of the image to load.
  final String imageUrl;

  /// Width of the image.
  final double? width;

  /// Height of the image.
  final double? height;

  /// How the image should fit inside its bounds.
  final BoxFit fit;

  /// Alignment of the image.
  final Alignment alignment;

  /// Optional border radius.
  final BorderRadius? borderRadius;

  /// Widget displayed while the image is loading.
  final Widget? placeholder;

  /// Widget displayed when image loading fails.
  final Widget? errorWidget;

  /// Whether to ignore the existing memory and disk cache.
  final bool forceRefresh;

  /// Optional custom cache manager.
  ///
  /// If omitted, the widget uses the default manager.
  final ImageCacheManager? cacheManager;

  /// Duration of the image fade-in animation.
  final Duration fadeInDuration;

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  static final ImageCacheManager _defaultCacheManager = ImageCacheManager();

  Uint8List? _imageBytes;

  Object? _error;

  bool _isLoading = true;

  ImageCacheManager get _manager => widget.cacheManager ?? _defaultCacheManager;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant CachedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final imageChanged = oldWidget.imageUrl != widget.imageUrl;

    final refreshChanged = oldWidget.forceRefresh != widget.forceRefresh;

    if (imageChanged || refreshChanged) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _imageBytes = null;
    });

    try {
      final bytes = await _manager.getImage(
        widget.imageUrl,
        forceRefresh: widget.forceRefresh,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _buildContent();

    if (widget.borderRadius == null) {
      return SizedBox(width: widget.width, height: widget.height, child: child);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(borderRadius: widget.borderRadius!, child: child),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return widget.placeholder ?? _defaultPlaceholder();
    }

    if (_error != null || _imageBytes == null) {
      return widget.errorWidget ?? _defaultErrorWidget();
    }

    return _buildImage(_imageBytes!);
  }

  Widget _buildImage(Uint8List bytes) {
    return Image.memory(
      bytes,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }

        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: widget.fadeInDuration,
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }

  Widget _defaultPlaceholder() {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return const Center(child: Icon(Icons.broken_image_outlined, size: 40));
  }
}
