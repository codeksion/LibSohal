import 'dart:io';

import 'package:flutter/services.dart';
//import 'package:image_picker/image_picker.dart';

class SohalCustomCamera {
  static const platform =
      MethodChannel('net.codeksion.libsohal.sohal_kutuphane/sohalcamera');

  Future<File> takePicture() async {
    final String path = await platform.invokeMethod("takePicture");
    return File(path);
  }
}
