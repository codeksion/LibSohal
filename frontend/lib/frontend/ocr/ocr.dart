//import 'package:flutter_mobile_vision_2/flutter_mobile_vision_2.dart';
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:sohal_kutuphane/service/service.dart';
import 'package:http/http.dart' as http;

Future<XFile?> pickImage() async {
  return ImagePicker().pickImage(source: ImageSource.camera);
}

Future<List<XFile>?> pickImageList() async {
  return ImagePicker().pickMultiImage();
}

Future<String?> pickImageAndOCR() async {
  var image = await pickImage();
  print("image $image");
  if (image == null) return null;
  var istek =
      http.MultipartRequest("POST", Uri.parse(Service.config.ApiURL + "/ocr"));

  print("image okunuyor");

  istek.files.add(await http.MultipartFile.fromPath("image", image.path));

  print("istek atılıyor");

  var yanit = await istek.send();
  if (yanit.statusCode != 200) {
    throw (json.decode(await yanit.stream.bytesToString()))["error"];
  }

  return await yanit.stream.bytesToString();

  /*try {
    return await SimpleOcrPlugin.performOCR(image.path);
  } catch (e) {
    print("pickImageAndOCR $e");
    return null;

  }*/

/*
  try {
    var list = await FlutterMobileVision.read(
      autoFocus: true,
      fps: 10,
      waitTap: true,
      showText: true,
      forceCloseCameraOnTap: true,
      //scanArea: Size(1000, 1000),
      //preview: Size(500, 500),

      flash: true,
      multiple: true,
      //imagePath:
    );
    print(list);

    for (var i in list) {
      print("list value: ${i.value}");
    }

    return list.map((e) => e.value).toString();
  } catch (e) {
    print("FlutterMobileVision.read $e");
    return null;
  }*/

  return "not impelemented";
}
