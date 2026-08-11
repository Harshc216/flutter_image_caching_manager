import 'package:flutter/material.dart';
import 'pages/image_caching_demo_page.dart';

void main() {
  runApp(const ImageCachingExampleApp());
}

/// Root widget of the Image Caching Manager example application.
class ImageCachingExampleApp extends StatelessWidget {
  const ImageCachingExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Caching Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const ImageCachingDemoPage(),
    );
  }
}
