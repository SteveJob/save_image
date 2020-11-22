import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SaveImage {
  /// channel
  static const MethodChannel _channel =
      const MethodChannel('aissz.com/save_image');

  /// save asset by path
  static Future<bool> saveAsset(String path, { bool videoMark = false }) async {
    if (path == null) return false;
    return await _channel.invokeMethod<bool>('saveAssetToGallery', <String, dynamic>{
      'path': path,
      'videoMark': videoMark
    });
  }
}
