import 'package:flutter/services.dart';

class NativeGallery {
  static const _channel = MethodChannel('native_gallery');

  static Future<List<String>> getImages() async {
    final List<dynamic> paths = await _channel.invokeMethod('getImages');
    return paths.cast<String>();
  }

  static Future<void> saveImage(String path) async {
    await _channel.invokeMethod('saveImage', {'path': path});
  }
}
